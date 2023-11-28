output "aws_api_gateway_deployment" {
  value = aws_api_gateway_deployment.api
}

output "aws_api_gateway_base_path_mapping" {
  value = aws_api_gateway_base_path_mapping.api
}

output "aws_api_gateway_rest_api" {
  value = aws_api_gateway_rest_api.api
}

output "api_gateway" {
  value = aws_api_gateway_usage_plan_key.main.value
}
