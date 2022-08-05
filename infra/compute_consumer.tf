locals {
  function_name_consumer = "consumer"
}

resource "aws_iam_role" "lambda_consumer_role" {
  provider           = aws.cloud
  name               = "lambda_consumer_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "archive_file" "python_lambda_consumer_package" {
  type = "zip"
  source {
    content = templatefile("files/consumer.py", {
      topic_url = "${aws_sns_topic.cloud_sns_serverless_rest_api.id}"
      table_url = "${aws_dynamodb_table.cloud_dynamodb_serverless_rest_api.id}"
    })
    filename = "consumer.py"
  }
  output_path = "files/consumer.zip"
}

# https://awspolicygen.s3.amazonaws.com/policygen.html
resource "aws_iam_policy" "lambda_consumer_sqs_receive_iam_policy" {
  name        = "lambda_consumer_sqs_receive_iam_policy"
  path        = "/"
  description = "IAM policy for reciving messages to Lambda from SQS"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ConsumerStatement",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Effect": "Allow",
      "Resource": "${aws_sqs_queue.cloud_sqs_serverless_rest_api.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_consumer_sns_publish_iam_policy" {
  name        = "lambda_consumer_sns_publish_iam_policy"
  path        = "/"
  description = "IAM policy for publish evento from Lambda to SNS"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1659644631574",
      "Action": [
        "sns:Publish"
      ],
      "Effect": "Allow",
      "Resource": "${aws_sns_topic.cloud_sns_serverless_rest_api.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_consumer_sqs" {
  role       = aws_iam_role.lambda_consumer_role.name
  policy_arn = aws_iam_policy.lambda_consumer_sqs_receive_iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_consumer_sns" {
  role       = aws_iam_role.lambda_consumer_role.name
  policy_arn = aws_iam_policy.lambda_consumer_sns_publish_iam_policy.arn
}

resource "aws_lambda_event_source_mapping" "event_source_mapping_sqs_lambda_consumer" {
  event_source_arn = aws_sqs_queue.cloud_sqs_serverless_rest_api.arn
  function_name    = aws_lambda_function.lambda_consumer.arn
}

resource "aws_lambda_function" "lambda_consumer" {
  provider         = aws.cloud
  filename         = "files/consumer.zip"
  function_name    = local.function_name_consumer
  role             = aws_iam_role.lambda_consumer_role.arn
  source_code_hash = filebase64sha256("files/consumer.zip")

  runtime = "python3.9"
  handler = "consumer.lambda_handler"
  timeout = 10

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_consumer_log_group" {
  provider          = aws.cloud
  name              = "/aws/lambda/${local.function_name_consumer}"
  retention_in_days = 1
}

resource "aws_iam_policy" "lambda_iam_consumer_logging" {
  provider    = aws.cloud
  name        = "lambda_logging_consumer"
  path        = "/"
  description = "IAM policy for logging from a lambda consumer"

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

resource "aws_iam_role_policy_attachment" "lambda_consumer_logs" {
  provider   = aws.cloud
  role       = aws_iam_role.lambda_consumer_role.name
  policy_arn = aws_iam_policy.lambda_iam_consumer_logging.arn
}