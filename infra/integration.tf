locals {
  emails = ["sebaczech@gmail.com"]
}

resource "aws_sqs_queue" "localstack_sqs_serverless_rest_api" {
  count    = var.create_services_on_localstack ? 1 : 0
  provider = aws.localstack
  name     = "localstack_sqs_serverless_rest_api"
}

resource "aws_sns_topic" "localstack_sns_serverless_rest_api" {
  count    = var.create_services_on_localstack ? 1 : 0
  provider = aws.localstack
  name     = "localstack_sns_serverless_rest_api"
}

# resource "aws_sqs_queue_policy" "cloud_sqs_serverless_rest_api_policy" {
#   provider  = aws.cloud
#   queue_url = aws_sqs_queue.cloud_sqs_serverless_rest_api.id

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "SqsStatement",
#       "Effect": "Allow",
#       "Principal": "*",
#       "Action": [
#         "lambda:CreateEventSourceMapping",
#         "lambda:ListEventSourceMappings",
#         "lambda:ListFunctions"
#       ],
#       "Resource": "${aws_lambda_function.lambda_consumer.arn}"
#     }
#   ]
# }
# EOF
# }

resource "aws_sqs_queue" "cloud_sqs_serverless_rest_api" {
  provider = aws.cloud
  name     = "cloud_sqs_serverless_rest_api"
}

resource "aws_sns_topic_subscription" "cloud_sns_topic_email_subscription" {
  count     = length(local.emails)
  topic_arn = aws_sns_topic.cloud_sns_serverless_rest_api.arn
  protocol  = "email"
  endpoint  = local.emails[count.index]
}

resource "aws_sns_topic" "cloud_sns_serverless_rest_api" {
  provider = aws.cloud
  name     = "cloud_sns_serverless_rest_api"
}
