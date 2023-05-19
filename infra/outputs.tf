output "producer_url" {
    value = aws_lambda_function_url.lambda_producer_endpoint.function_url
}