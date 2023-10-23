
module "cloud_relay" {
source = "../../module/main"
name = "123-6536db027ff9aaf48b75b278"
env = var.env
cidr = Input is not an array
ring_central_subnet = [""]

vpn_connection_static_routes_destinations = Input is not an array
customer_gateway_ip_address = Input is not an array
vpn_connection_tunnel1_phase1_encryption_algorithms = [""]
vpn_connection_tunnel1_phase1_integrity_algorithms = [""]
vpn_connection_tunnel1_phase_1_lifetime = "3600"
vpn_connection_tunnel1_phase1_dh_group_numbers = []
vpn_connection_tunnel1_phase2_encryption_algorithms = [""]
vpn_connection_tunnel1_phase2_integrity_algorithms = [""]
vpn_connection_tunnel1_phase_2_lifetime = ""
vpn_connection_tunnel1_phase2_dh_group_numbers = []
vpn_connection_rekey_margin_time = 540
vpn_connection_rekey_fuzz = 100
vpn_connection_replay_window = 1024
vpn_customer_gateway_bgp_asn = 65002
vpn_connection_dead_peer_detection = 30
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