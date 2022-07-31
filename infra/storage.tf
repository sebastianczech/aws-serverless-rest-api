resource "aws_s3_bucket" "localstack_s3_serverless_rest_api_bucket" {
  provider = aws.localstack
  bucket   = "localstack-s3-serverless-rest-api"
}

resource "aws_s3_object" "data_json" {
  provider = aws.localstack
  bucket   = aws_s3_bucket.localstack_s3_serverless_rest_api_bucket.id
  key      = "data_json"
  source   = "files/data.json"
}
