
# https://www.terraform.io/docs/providers/aws/r/customer_gateway.html
resource "aws_customer_gateway" "default" {
  bgp_asn    = var.vpn_customer_gateway_bgp_asn
  ip_address = var.customer_gateway_ip_address
  type       = "ipsec.1"
  tags = {
    Name = "cr-cgw-${var.name}"
  }
}

# https://www.terraform.io/docs/providers/aws/r/vpn_connection.html
resource "aws_vpn_connection" "default" {
  tags = {
    Name = "cr-vpn-${var.name}"
  }
  vpn_gateway_id           = var.aws_vpn_gateway
  customer_gateway_id      = aws_customer_gateway.default.id
  type                     = "ipsec.1"
  static_routes_only       = var.vpn_connection_static_routes_only

  # This is backwards since VPN naming conventions is garbage !!!
  local_ipv4_network_cidr  = var.vpn_connection_remote_ipv4_network_cidr
  remote_ipv4_network_cidr = var.vpn_connection_local_ipv4_network_cidr

  tunnel1_startup_action     = var.vpn_connection_startup_action
  tunnel1_dpd_timeout_action = var.dpd_timeout_action
  tunnel1_ike_versions       = var.vpn_connection_tunnel1_ike_versions
  tunnel1_inside_cidr        = var.vpn_connection_tunnel1_inside_cidr
  tunnel1_preshared_key      = var.vpn_connection_tunnel1_preshared_key

  tunnel1_phase1_dh_group_numbers      = var.vpn_connection_tunnel1_phase1_dh_group_numbers
  tunnel1_phase2_dh_group_numbers      = var.vpn_connection_tunnel1_phase2_dh_group_numbers
  tunnel1_phase1_lifetime_seconds      = var.vpn_connection_tunnel1_phase_1_lifetime
  tunnel1_phase2_lifetime_seconds      = var.vpn_connection_tunnel1_phase_2_lifetime
  tunnel1_rekey_margin_time_seconds    = var.vpn_connection_rekey_margin_time
  tunnel1_rekey_fuzz_percentage        = var.vpn_connection_rekey_fuzz
  tunnel1_replay_window_size           = var.vpn_connection_replay_window
  tunnel1_phase1_encryption_algorithms = var.vpn_connection_tunnel1_phase1_encryption_algorithms
  tunnel1_phase2_encryption_algorithms = var.vpn_connection_tunnel1_phase2_encryption_algorithms
  tunnel1_phase1_integrity_algorithms  = var.vpn_connection_tunnel1_phase1_integrity_algorithms
  tunnel1_phase2_integrity_algorithms  = var.vpn_connection_tunnel1_phase2_integrity_algorithms

  tunnel2_startup_action     = var.vpn_connection_startup_action
  tunnel2_dpd_timeout_action = var.dpd_timeout_action
  tunnel2_ike_versions       = var.vpn_connection_tunnel2_ike_versions
  tunnel2_inside_cidr        = var.vpn_connection_tunnel2_inside_cidr
  tunnel2_preshared_key      = var.vpn_connection_tunnel2_preshared_key

  tunnel2_phase1_dh_group_numbers      = var.vpn_connection_tunnel2_phase1_dh_group_numbers
  tunnel2_phase2_dh_group_numbers      = var.vpn_connection_tunnel2_phase2_dh_group_numbers
  tunnel2_phase1_lifetime_seconds      = var.vpn_connection_tunnel1_phase_1_lifetime
  tunnel2_phase2_lifetime_seconds      = var.vpn_connection_tunnel1_phase_2_lifetime
  tunnel2_rekey_margin_time_seconds    = var.vpn_connection_rekey_margin_time
  tunnel2_rekey_fuzz_percentage        = var.vpn_connection_rekey_fuzz
  tunnel2_replay_window_size           = var.vpn_connection_replay_window
  tunnel2_phase1_encryption_algorithms = var.vpn_connection_tunnel2_phase1_encryption_algorithms
  tunnel2_phase2_encryption_algorithms = var.vpn_connection_tunnel2_phase2_encryption_algorithms
  tunnel2_phase1_integrity_algorithms  = var.vpn_connection_tunnel2_phase1_integrity_algorithms
  tunnel2_phase2_integrity_algorithms  = var.vpn_connection_tunnel2_phase2_integrity_algorithms

}

# https://www.terraform.io/docs/providers/aws/r/vpn_gateway_route_propagation.html
resource "aws_vpn_gateway_route_propagation" "default" {
  count          = length(var.route_table_ids)
  vpn_gateway_id = var.aws_vpn_gateway
  route_table_id = element(var.route_table_ids, count.index)
}

# https://www.terraform.io/docs/providers/aws/r/vpn_connection_route.html
resource "aws_vpn_connection_route" "default" {
  count                  = var.vpn_connection_static_routes_only == "true" ? length(var.vpn_connection_static_routes_destinations) : 0
  vpn_connection_id      = aws_vpn_connection.default.id
  destination_cidr_block = element(var.vpn_connection_static_routes_destinations, count.index)
}


resource "aws_route" "private_routing" {
  count                     = var.vpn_connection_static_routes_only == "true" ? length(var.vpn_connection_static_routes_destinations) : 0
  route_table_id            = var.vpn_route_table_private
  destination_cidr_block    = element(var.vpn_connection_static_routes_destinations, count.index)
  gateway_id                = var.aws_vpn_gateway
  depends_on                = [var.aws_vpn_gateway]
}

resource "aws_route" "public_routing" {
  count                     = var.vpn_connection_static_routes_only == "true" ? length(var.vpn_connection_static_routes_destinations) : 0
  route_table_id            = var.vpn_route_table_public
  destination_cidr_block    = element(var.vpn_connection_static_routes_destinations, count.index)
  gateway_id                = var.aws_vpn_gateway
  depends_on                = [var.aws_vpn_gateway]
}