resource "aws_dynamodb_table" "localstack_dynamodb_serverless_rest_api" {
  provider       = aws.localstack
  name           = "localstack_dynamodb_serverless_rest_api"
  read_capacity  = "20"
  write_capacity = "20"
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "cloud_dynamodb_serverless_rest_api" {
  provider       = aws.cloud
  name           = "cloud_dynamodb_serverless_rest_api"
  read_capacity  = "20"
  write_capacity = "20"
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
}