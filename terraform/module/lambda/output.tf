output "relay_lambda_function" {
  value = aws_lambda_function.relay_lambda_function
}

output "authorizer_lambda_function" {
  value = aws_lambda_function.authorizer_lambda_function
}

output "lambda_execution_role" {
  value = aws_iam_role.lambda_execution_role
}

output "apisecret" {
  value = random_id.api.hex
}
