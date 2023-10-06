locals {
  function_name_producer = "${var.prefix}producer"
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  provider = aws.cloud
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_producer_role" {
  provider           = aws.cloud
  name               = "${var.prefix}lambda_producer_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "archive_file" "python_lambda_producer_package" {
  type = "zip"
  # source_file = "files/producer.py"
  source {
    content = templatefile("files/producer.py", {
      queue_url = "${aws_sqs_queue.cloud_sqs_serverless_rest_api.id}"
    })
    filename = "producer.py"
  }
  output_path = "files/producer.zip"
}

# https://awspolicygen.s3.amazonaws.com/policygen.html
resource "aws_iam_policy" "lambda_producer_sqs_send_iam_policy" {
  name        = "${var.prefix}lambda_producer_sqs_send_iam_policy"
  path        = "/"
  description = "IAM policy for sending messages to SQS from a Lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ProducerStatement",
      "Action": [
        "sqs:SendMessage"
      ],
      "Effect": "Allow",
      "Resource": "${aws_sqs_queue.cloud_sqs_serverless_rest_api.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_producer_sqs" {
  role       = aws_iam_role.lambda_producer_role.name
  policy_arn = aws_iam_policy.lambda_producer_sqs_send_iam_policy.arn
}

resource "aws_lambda_function" "lambda_producer" {
  provider         = aws.cloud
  filename         = "files/producer.zip"
  function_name    = local.function_name_producer
  role             = aws_iam_role.lambda_producer_role.arn
  source_code_hash = filebase64sha256("files/producer.zip")

  runtime = "python3.9"
  handler = "producer.lambda_handler"
  timeout = 10

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_producer_log_group" {
  provider          = aws.cloud
  name              = "/aws/lambda/${local.function_name_producer}"
  retention_in_days = 1
}

resource "aws_iam_policy" "lambda_iam_producer_logging" {
  provider    = aws.cloud
  name        = "${var.prefix}lambda_logging_producer"
  path        = "/"
  description = "IAM policy for logging from a lambda producer"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_producer_logs" {
  provider   = aws.cloud
  role       = aws_iam_role.lambda_producer_role.name
  policy_arn = aws_iam_policy.lambda_iam_producer_logging.arn
}

resource "aws_lambda_function_url" "lambda_producer_endpoint" {
  provider           = aws.cloud
  function_name      = aws_lambda_function.lambda_producer.function_name
  authorization_type = "AWS_IAM" # "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}

data "aws_iam_user" "iam_user_seba" {
  provider  = aws.cloud
  user_name = "seba"
}

resource "aws_lambda_permission" "allow_iam_user" {
  provider               = aws.cloud
  statement_id           = "AllowExecutionForIamUser"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.lambda_producer.function_name
  function_url_auth_type = "AWS_IAM"
  principal              = data.aws_iam_user.iam_user_seba.arn
}

# resource "aws_lambda_permission" "allow_all" {
#   provider               = aws.cloud
#   statement_id           = "FunctionURLAllowPublicAccess"
#   action                 = "lambda:InvokeFunctionUrl"
#   function_name          = aws_lambda_function.lambda_producer.function_name
#   function_url_auth_type = "NONE"
#   principal              = "*"
# }

check "lambda_deployed" {
  data "external" "this" {
    program = ["curl", "${aws_lambda_function_url.lambda_producer_endpoint.function_url}"]
  }

  assert {
    # If we execution function using URL without authentication, then it should be received forbidden message, if Lambda is deployed correctly
    condition = data.external.this.result.Message == "Forbidden"
    error_message = format("The Lambda %s is not deployed.",
      aws_lambda_function.lambda_producer.function_name
    )
  }
}
