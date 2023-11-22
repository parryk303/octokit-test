
    module "cloud_relay" {
      source              = "../../module/main"
      name                = "007-655e37d95714f0813a9cc831"
      env                 = var.env
      cidr                = "172.31.0.0/28"
      private_subnets = [172.31.0.0/27]
      public_subnets  = [172.31.0.32/27]

      ring_central_subnet = ["172.31.0.0/28"]

      relay_package_location      = "lambdas_code/relay-lambda-code.zip"
      authorizer_package_location = "lambdas_code/authorizer-lambda-code.zip"

      vpn_connection_static_routes_destinations           = Input is not an array
      customer_gateway_ip_address                         = ["172.31.0.0"]
      vpn_connection_tunnel1_phase1_encryption_algorithms = ["AES128"]
      vpn_connection_tunnel1_phase1_integrity_algorithms  = ["SHA1"]
      vpn_connection_tunnel1_phase_1_lifetime             = "3600"
      vpn_connection_tunnel1_phase1_dh_group_numbers      = [2]
      vpn_connection_tunnel1_phase2_encryption_algorithms = ["AES256"]
      vpn_connection_tunnel1_phase2_integrity_algorithms  = ["SHA1"]
      vpn_connection_tunnel1_phase_2_lifetime             = "3600"
      vpn_connection_tunnel1_phase2_dh_group_numbers      = [5]
      vpn_connection_rekey_margin_time                    = 540
      vpn_connection_rekey_fuzz                           = 100
      vpn_connection_replay_window                        = 1024
      vpn_customer_gateway_bgp_asn                        = 65000
      vpn_connection_dead_peer_detection                  = 30

      vpn_connection_local_ipv4_network_cidr              = none
      vpn_connection_remote_ipv4_network_cidr             = 172.31.0.0/27
      vpn_connection_static_routes_only                   = static
      vpn_connection_startup_action                       = start
      vpn_connection_tunnel1_ike_versions                 = ikev1
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