
  module "cloud_relay" {
    source              = "../../module/main"
    name                = "FROSTYGOODALL"
    env                 = var.env
    cidr                = "192.168.0.0/26"
    private_subnets     = ["192.168.0.0/28", "192.168.0.16/28"]
    public_subnets      = ["192.168.0.32/27"]

    relay_package_location      = "lambdas_code/relay-lambda-code.zip"
    authorizer_package_location = "lambdas_code/authorizer-lambda-code.zip"

    vpn_connection_static_routes_destinations           = ["192.168.2.0/24"]
    customer_gateway_ip_address                         = ["200.1.2.3"]
    vpn_connection_tunnel1_phase1_encryption_algorithms = ["AES256"]
    vpn_connection_tunnel1_phase1_integrity_algorithms  = ["SHA2-512"]
    vpn_connection_tunnel1_phase_1_lifetime             = "3600"
    vpn_connection_tunnel1_phase1_dh_group_numbers      = [24]
    vpn_connection_tunnel1_phase2_encryption_algorithms = ["AES256"]
    vpn_connection_tunnel1_phase2_integrity_algorithms  = ["SHA2-512"]
    vpn_connection_tunnel1_phase_2_lifetime             = "3600"
    vpn_connection_tunnel1_phase2_dh_group_numbers      = [24]
    vpn_connection_rekey_margin_time                    = 540
    vpn_connection_rekey_fuzz                           = 100
    vpn_connection_replay_window                        = 1024
    vpn_customer_gateway_bgp_asn                        = 65000
    vpn_connection_dead_peer_detection                  = 30
}


