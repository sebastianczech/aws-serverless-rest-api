resource "aws_dynamodb_table" "localstack_dynamodb_serverless_rest_api" {
  count          = var.create_services_on_localstack ? 1 : 0
  provider       = aws.localstack
  name           = "${var.prefix}localstack_dynamodb_serverless_rest_api"
  read_capacity  = "1"
  write_capacity = "1"
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "cloud_dynamodb_serverless_rest_api" {
  provider       = aws.cloud
  name           = "${var.prefix}cloud_dynamodb_serverless_rest_api"
  read_capacity  = "1"
  write_capacity = "1"
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
}