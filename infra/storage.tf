resource "aws_s3_bucket" "localstack_s3_serverless_rest_api_bucket" {
  count    = var.create_services_on_localstack ? 1 : 0
  provider = aws.localstack
  bucket   = "${var.prefix}localstack-s3-serverless-rest-api"
}

resource "aws_s3_object" "data_json" {
  count    = var.create_services_on_localstack ? 1 : 0
  provider = aws.localstack
  bucket   = aws_s3_bucket.localstack_s3_serverless_rest_api_bucket[0].id
  key      = "data_json"
  source   = "files/data.json"
}
