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
  name               = "lambda_producer_role"
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
  name        = "lambda_producer_sqs_send_iam_policy"
  path        = "/"
  description = "IAM policy for sending messages to SQS from a Lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1659292411789",
      "Action": [
        "sqs:SendMessage"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:sqs:us-east-1:884522662008:cloud_sqs_serverless_rest_api"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_producer_role.name
  policy_arn = aws_iam_policy.lambda_producer_sqs_send_iam_policy.arn
}

resource "aws_lambda_function" "lambda_producer" {
  provider         = aws.cloud
  filename         = "files/producer.zip"
  function_name    = "producer"
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
