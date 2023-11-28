output "name" {
  value = var.name
}

output "main_regions" {
  value = var.aws_region
}

output "backup_regions" {
  value = var.aws_region_b
}

output "API_url" {
  value = var.enable_lambda_build ? var.enable_api_gateway ? module.api_gateway.0.aws_api_gateway_base_path_mapping.id : "API creation is disabled" : "Lambda creation is disabled"
}

output "backup_API_url" {
  value = var.enable_lambda_build ? var.enable_api_gateway ? module.api_gateway_b.0.aws_api_gateway_base_path_mapping.id : "API creation is disabled" : "Lambda creation is disabled"
}

output "api_key" {
  value      = var.enable_lambda_build ? var.enable_api_gateway ? module.api_gateway.0.api_gateway : "API creation is disabled" : "Lambda creation is disabled"
}

output "backup_api_key" {
  value      = var.enable_lambda_build ? var.enable_api_gateway ? module.api_gateway_b.0.api_gateway : "API creation is disabled" : "Lambda creation is disabled"
}

output "apisecret" {
  value     = var.enable_lambda_build ? var.enable_api_gateway ? module.secret.0.apisecret : "API creation is disabled" : "Lambda creation is disabled"
}

