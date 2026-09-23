
  module "cloud_relay" {
    source              = "../../module/main"
    name                = "JOVIALWRIGHT"
    env                 = var.env
    cidr                = "172.31.0.0/26"
    private_subnets     = ["172.31.0.0/28", "172.31.0.16/28"]
    public_subnets      = ["172.31.0.32/27"]

    relay_package_location      = "lambdas_code/relay-lambda-code.zip"
    authorizer_package_location = "lambdas_code/authorizer-lambda-code.zip"

    vpn_connection_static_routes_destinations           = ["none"]
    customer_gateway_ip_address                         = ["192.0.2.1"]
    vpn_connection_tunnel1_phase1_encryption_algorithms = ["AES128-GCM-16"]
    vpn_connection_tunnel1_phase1_integrity_algorithms  = ["SHA2-384"]
    vpn_connection_tunnel1_phase_1_lifetime             = "3600"
    vpn_connection_tunnel1_phase1_dh_group_numbers      = [19]
    vpn_connection_tunnel1_phase2_encryption_algorithms = ["AES256-GCM-16"]
    vpn_connection_tunnel1_phase2_integrity_algorithms  = ["SHA2-256"]
    vpn_connection_tunnel1_phase_2_lifetime             = "3600"
    vpn_connection_tunnel1_phase2_dh_group_numbers      = [17]
    vpn_connection_rekey_margin_time                    = 540
    vpn_connection_rekey_fuzz                           = 105
    vpn_connection_replay_window                        = 1025
    vpn_customer_gateway_bgp_asn                        = 65000
    vpn_connection_static_routes_only                   = false
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

