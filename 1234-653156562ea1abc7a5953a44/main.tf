
module "cloud_relay" {
source = "../../module/main"
name = "1234-653156562ea1abc7a5953a44"
env = var.env
cidr = "Input is not an array"
ring_central_subnet = []

relay_package_location = "lambdas_code/relay-lambda-code.zip"
authorizer_package_location = "lambdas_code/authorizer-lambda-code.zip"

enable_vpn_build = false
}


output "project_name" {
value = module.cloud_relay.name
}

output "project_env" {
value = var.env
}

output "main_regions" {
value = module.cloud_relay.main_regions
}

output "backup_regions" {
value = module.cloud_relay.backup_regions
}

output "API_url" {
value = module.cloud_relay.API_url
}

output "backup_API_url" {
value = module.cloud_relay.backup_API_url
}

output "apisecret" {
value = module.cloud_relay.apisecret
sensitive = true
}

output "api_key" {
value = module.cloud_relay.api_key
sensitive = true
}

output "backup_api_key" {
value = module.cloud_relay.backup_api_key
sensitive = true
}