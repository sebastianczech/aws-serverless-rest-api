resource "aws_sqs_queue" "localstack_sqs_serverless_rest_api" {
  provider = aws.localstack
  name     = "localstack_sqs_serverless_rest_api"
}

resource "aws_sns_topic" "localstack_sns_serverless_rest_api" {
  provider = aws.localstack
  name     = "localstack_sns_serverless_rest_api"
}

resource "aws_sqs_queue" "cloud_sqs_serverless_rest_api" {
  provider = aws.cloud
  name     = "cloud_sqs_serverless_rest_api"
}

resource "aws_sns_topic" "cloud_sns_serverless_rest_api" {
  provider = aws.cloud
  name     = "cloud_sns_serverless_rest_api"
}
