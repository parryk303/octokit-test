##### Mandatory variables #####

variable "name" {
  description = "Name of the project"
  type        = string
}

variable "env" {
  description = "Set enviroment"
  type        = string
}

##### None mandatory variables #####

variable "enable_api_gateway" {
  description = "Enable api_gateway builds"
  type        = bool
  default     = true
}

variable "enable_vpn_build" {
  description = "Enable vpn builds"
  type        = bool
  default     = true
}

variable "enable_lambda_build" {
  description = "Enable lambda builds"
  type        = bool
  default     = true
}

variable "relay_package_location" {
  description = "Package path for the lambda content"
  type        = string
  default     = ".terraform/modules/cloud_relay/terraform/module/main/default_lambda_code/relay-golden.zip"
}

variable "authorizer_package_location" {
  description = "Package path for the lambda content"
  type        = string
  default     = ".terraform/modules/cloud_relay/terraform/module/main/default_lambda_code/authorizer-golden.zip"
}

variable "aws_region" {
  description = "Set AWS region"
  type        = string
  default     = "us-east-2"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = [ "us-east-2a", "us-east-2b"]
}

variable "aws_region_b" {
  description = "Set AWS region"
  type        = string
  default     = "us-west-2"
}

variable "azs_b" {
  description = "Availability zones"
  type        = list(string)
  default     = [ "us-west-2a", "us-west-2b"]
}

variable "aws_profile" {
  description = "Set AWS profile"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "VPC cidr"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "Private subnet cidr"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "Public subnet cidr"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "enable_nat_gateway" {
  description = "enable nat gateway on VPC"
  type        = string
  default     = true
}

variable "single_nat_gateway" {
  description = "single nat gateway on VPC"
  type        = string
  default     = true
}

variable "one_nat_gateway_per_az" {
  description = "one nat gateway per az on VPC"
  type        = string
  default     = false
}

variable "manage_default_network_acl" {
  description = "manage_default_network_acl on VPC"
  type        = string
  default     = true
}

variable "enable_dns_hostnames" {
  description = "enable_dns_hostnames on VPC"
  type        = string
  default     = true
}

variable "enable_dns_support" {
  description = "enable_dns_support on VPC"
  type        = string
  default     = true
}

variable "sendcertificate" {
  description = "Lambda variable"
  type        = string
  default     = "false"
}

variable "certificatepath" {
  description = "Lambda variable"
  type        = string
  default     = ""
}

variable "certificatepassphrase" {
  description = "Lambda variable"
  type        = string
  default     = ""
}

variable "certificatekeypath" {
  description = "Lambda variable"
  type        = string
  default     = ""
}

variable "quota_settings_limit" {
  description = "quota_settings limit"
  type        = string
  default     = "5000000"
}

variable "quota_settings_offset" {
  description = "quota_settings offset"
  type        = string
  default     = "2"
}

variable "quota_settings_period" {
  description = "quota_settings period"
  type        = string
  default     = "MONTH"
}

variable "throttle_settings_burst_limit" {
  description = "throttle_settings burst_limit"
  type        = string
  default     = "1000"
}

variable "vpn_connection_startup_action" {
  description = "vpn_connection_startup_action"
  type        = string
  default     = "add"
}

variable "throttle_settings_rate_limit" {
  description = "throttle_settings rate_limit"
  type        = string
  default     = "200"
}

variable "set_secret" {
  description = "set_secret"
  type        = string
  default     = ""
}

variable "aws_iam_access_key_name" {
  description = "Set the IAM user for the relay lambda"
  type        = string
  default     = "cloud-relay-secrets-manager"
}

variable "dpd_timeout_action" {
  type        = string
  description = "The action to take after DPD timeout occurs for the first VPN tunnel. Specify restart to restart the IKE initiation. Specify clear to end the IKE session. Valid values are clear | none | restart."
  default     = "restart"
}

variable "customer_gateway_ip_address" {
  description = "The IP address of the gateway's Internet-routable external interface"
  type        = list(string)
  default     = []
}

variable "vpn_connection_tunnel1_ike_versions" {
  description = "vpn_connection_tunnel1_ike_versions"
  type        = list(string)
  default     = []
}

variable "vpn_connection_tunnel2_ike_versions" {
  description = "vpn_connection_tunnel2_ike_versions"
  type        = list(string)
  default     = []
}

variable "vpn_connection_static_routes_only" {
  description = "vpn_connection_static_routes_only"
  type        = string
  default     = true
}

variable "vpn_connection_local_ipv4_network_cidr" {
  description = "vpn_connection_local_ipv4_network_cidr"
  type        = string
  default     = "none"
}

variable "vpn_connection_remote_ipv4_network_cidr" {
  description = "vpn_connection_local_ipv4_network_cidr"
  type        = string
  default     = "none"
}

variable "vpn_customer_gateway_bgp_asn" {
  description = "vpn_bgp_asn"
  type        = string
  default     = "65000"
}

variable "vpn_connection_static_routes_destinations" {
  description = "List of CIDR blocks to be used as destination for static routes. Routes to destinations will be propagated to the route tables defined in `route_table_ids`"
  type        = list(string)
  default     = []
}

variable "route_table_ids" {
  description = "The IDs of the route tables for which routes from the Virtual Private Gateway will be propagated"
  type        = list(string)
  default     = []
}

variable "vpn_connection_tunnel1_phase1_encryption_algorithms" {
  description = "Set vpn_connection_tunnel1_phase1_encryption_algorithms"
  type        = list(string)
  default     = []
}

variable "vpn_connection_tunnel1_preshared_key" {
  description = "Set vpn_connection_tunnel1_preshared_key"
  type        = string
  default     = null
}

variable "vpn_connection_tunnel2_preshared_key" {
  description = "Set vpn_connection_tunnel2_preshared_key"
  type        = string
  default     = null
}

variable "vpn_connection_tunnel1_phase1_integrity_algorithms" {
  description = "Set vpn_connection_tunnel1_phase1_integrity_algorithms"
  type        = list(string)
  default     = []
}

variable "vpn_connection_tunnel1_phase1_dh_group_numbers" {
  description = "Set vpn_connection_tunnel1_phase1_dh_group_numbers"
  type        = list(string)
  default     = []
}

variable "vpn_connection_tunnel1_phase2_encryption_algorithms" {
  description = "Set vpn_connection_tunnel1_phase2_encryption_algorithms"
  type        = list(string)
  default     = []
}

variable "vpn_connection_tunnel1_phase2_integrity_algorithms" {
  description = "Set vpn_connection_tunnel1_phase2_integrity_algorithms"
  type        = list(string)
  default     = []
}

variable "vpn_connection_tunnel1_phase2_dh_group_numbers" {
  description = "Set vpn_connection_tunnel1_phase2_dh_group_numbers"
  type        = list(string)
  default     = []
}

variable "vpn_connection_tunnel1_phase_1_lifetime" {
  description = "Set vpn_connection_tunnel1_phase_1_lifetime"
  type        = string
  default     = "3600"
}

variable "vpn_connection_tunnel1_phase_2_lifetime" {
  description = "Set vpn_connection_tunnel1_phase_2_lifetime"
  type        = string
  default     = "3600"
}

variable "vpn_connection_rekey_margin_time" {
  description = "Set vpn_connection_rekey_margin_time"
  type        = string
  default     = "540"
}

variable "vpn_connection_rekey_fuzz" {
  description = "Set vpn_connection_rekey_fuzz"
  type        = string
  default     = "100"
}

variable "vpn_connection_replay_window" {
  description = "Set vpn_connection_replay_window"
  type        = string
  default     = "1024"
}

variable "vpn_connection_dead_peer_detection" {
  description = "Set vpn_connection_dead_peer_detection"
  type        = string
  default     = ""
}

variable "relay_extra_variables" {
  description = "Add extra relay enviroment variables"
  type        = map(string)
  default = {}
}

variable "auth_extra_variables" {
  description = "Add extra auth enviroment variables"
  type        = map(string)
  default = {}
}
