run "check_producer_lambda_url" {

  command = apply

  variables {
    prefix = "test"
  }

  assert {
    condition     = length(aws_lambda_function_url.lambda_producer_endpoint.function_url) > 0
    error_message = "Lambda producer URL should not be empty"
  }

}