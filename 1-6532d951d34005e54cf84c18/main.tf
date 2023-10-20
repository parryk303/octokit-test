
module "cloud_relay" {
source = "../../module/main"
name = "1-6532d951d34005e54cf84c18"
env = var.env
cidr = ["192.168.0.0/26", "192.168.0.0/26", "192.168.0.0/26"]
ring_central_subnet = ["192.168.0.0/28"]

vpn_connection_static_routes_destinations = ["10.1.1.19"]
customer_gateway_ip_address = ["10.1.1.19"]
vpn_connection_tunnel1_phase1_encryption_algorithms = ["AES128"]
vpn_connection_tunnel1_phase1_integrity_algorithms = ["SHA1"]
vpn_connection_tunnel1_phase_1_lifetime = "3600"
vpn_connection_tunnel1_phase1_dh_group_numbers = [19]
vpn_connection_tunnel1_phase2_encryption_algorithms = ["AES128"]
vpn_connection_tunnel1_phase2_integrity_algorithms = ["SHA1"]
vpn_connection_tunnel1_phase_2_lifetime = ""
vpn_connection_tunnel1_phase2_dh_group_numbers = [19]
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