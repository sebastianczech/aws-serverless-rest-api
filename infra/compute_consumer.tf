resource "aws_iam_role" "lambda_consumer_role" {
  provider           = aws.cloud
  name               = "lambda_consumer_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "archive_file" "python_lambda_consumer_package" {
  type = "zip"
  source {
    content = templatefile("files/consumer.py", {

    })
    filename = "consumer.py"
  }
  output_path = "files/consumer.zip"
}

# # https://awspolicygen.s3.amazonaws.com/policygen.html
# resource "aws_iam_policy" "lambda_consumer_sqs_send_iam_policy" {
#   name        = "lambda_consumer_sqs_send_iam_policy"
#   path        = "/"
#   description = "IAM policy for sending messages to SQS from a Lambda"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "Stmt1659292411789",
#       "Action": [
#         "sqs:SendMessage"
#       ],
#       "Effect": "Allow",
#       "Resource": "arn:aws:sqs:us-east-1:884522662008:cloud_sqs_serverless_rest_api"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "lambda_consumer_sqs" {
#   role       = aws_iam_role.lambda_consumer_role.name
#   policy_arn = aws_iam_policy.lambda_consumer_sqs_send_iam_policy.arn
# }

resource "aws_lambda_function" "lambda_consumer" {
  provider         = aws.cloud
  filename         = "files/consumer.zip"
  function_name    = "consumer"
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