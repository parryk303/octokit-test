##################################################################
#####                   Cloud Relay Module                   #####
##################################################################


##################################################################
# Main resources 
##################################################################

provider "aws" {
  
  alias = "main_resource"
  
  default_tags {
    tags = {
      Project     = var.name
      Subsystem   = "cloudRelay"
      Environment = var.env
      Deployment  = "terraform"
      Costcenter  = 135
      Team        = "PSi"
    }
  }

  region   = var.aws_region
  profile  = var.aws_profile
}

locals {
  format_stage = split("-", var.aws_region)
  stage_name   = "${local.format_stage[0]}${local.format_stage[1]}-${var.env}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  #version = "4.0.2"

  name = "cr-vpc-${var.name}-${var.env}"
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway         = var.enable_nat_gateway
  single_nat_gateway         = var.single_nat_gateway
  one_nat_gateway_per_az     = var.one_nat_gateway_per_az
  manage_default_network_acl = var.manage_default_network_acl
  enable_dns_hostnames       = var.enable_dns_hostnames
  enable_dns_support         = var.enable_dns_support

  providers = {
    aws = aws.main_resource
  }

}

module "lambda" {
  source = "../lambda"
  count  = var.enable_lambda_build ? 1 : 0

  name                        = var.name
  env                         = var.env
  cidr                        = var.cidr
  vpc_id                      = module.vpc.vpc_id
  stage_name                  = local.stage_name
  aws_region                  = var.aws_region
  format_stage                = local.format_stage
  private_subnets             = module.vpc.private_subnets
  relay_package_location      = var.relay_package_location
  authorizer_package_location = var.authorizer_package_location
  sendcertificate             = var.sendcertificate
  certificatepath             = var.certificatepath
  certificatepassphrase       = var.certificatepassphrase
  certificatekeypath          = var.certificatekeypath
  auth_extra_variables        = var.auth_extra_variables
  relay_extra_variables       = var.relay_extra_variables

  providers = {
    aws = aws.main_resource
  }

}

module "secret" {
  source = "../secret"
  count  = var.enable_lambda_build && var.enable_api_gateway ? 1 : 0
  name   = var.name
  env    = var.env
  set_secret    = var.set_secret
  backup_region = var.aws_region_b
  
  providers = {
    aws = aws.main_resource
  }
}

module "api_gateway" {
  source = "../api_gateway"
  count  = var.enable_lambda_build && var.enable_api_gateway ? 1 : 0
  
  env                           = var.env
  name                          = var.name
  aws_region                    = var.aws_region
  stage_name                    = local.stage_name
  domain_name                   = var.env == "production" ? "cloudrelay.ps.ringcentral.com" : var.env == "dev" ? "dev.ringcentralps.com" : "staging-cloudrelay.ps.ringcentral.com" 
  quota_settings_limit          = var.quota_settings_limit
  quota_settings_offset         = var.quota_settings_offset
  quota_settings_period         = var.quota_settings_period
  throttle_settings_burst_limit = var.throttle_settings_burst_limit
  throttle_settings_rate_limit  = var.throttle_settings_rate_limit

  authorizer_lambda_function = module.lambda.0.authorizer_lambda_function.invoke_arn
  relay_lambda_function      = module.lambda.0.relay_lambda_function.invoke_arn

  providers = {
    aws = aws.main_resource
  }

}

resource "aws_vpn_gateway" "default" {
  count  = var.enable_vpn_build ? 1 : 0
  vpc_id          = module.vpc.vpc_id
  amazon_side_asn = 64512
  
  tags = {
    Name = "cr-vpg-${var.name}-${var.env}"
  }

  provider = aws.main_resource
}

module "vpn" {
  source = "../vpn"
  count  = var.enable_vpn_build ? length(var.customer_gateway_ip_address) : 0

  name                                      = "${var.name}-${count.index}-${var.env}"
  env                                       = var.env
  vpc_id                                    = module.vpc.vpc_id
  route_table_ids                           = var.route_table_ids
  aws_vpn_gateway                           = aws_vpn_gateway.default.0.id
  customer_gateway_ip_address               = var.customer_gateway_ip_address[count.index]
  vpn_connection_static_routes_destinations = var.vpn_connection_static_routes_destinations
  vpn_connection_local_ipv4_network_cidr    = var.vpn_connection_local_ipv4_network_cidr == "none" ? replace(var.private_subnets[0], "/28", "/26") : var.vpn_connection_local_ipv4_network_cidr
  vpn_connection_remote_ipv4_network_cidr   = var.vpn_connection_remote_ipv4_network_cidr == "none" ? var.vpn_connection_static_routes_destinations[0] : var.vpn_connection_remote_ipv4_network_cidr
  vpn_connection_startup_action             = var.vpn_connection_startup_action
  dpd_timeout_action                        = var.dpd_timeout_action
  vpn_customer_gateway_bgp_asn              = var.vpn_customer_gateway_bgp_asn
  vpn_connection_static_routes_only         = var.vpn_connection_static_routes_only

  vpn_connection_tunnel1_ike_versions                  = var.vpn_connection_tunnel1_ike_versions 
  vpn_connection_tunnel1_phase1_encryption_algorithms  = var.vpn_connection_tunnel1_phase1_encryption_algorithms
  vpn_connection_tunnel1_phase1_integrity_algorithms   = var.vpn_connection_tunnel1_phase1_integrity_algorithms
  vpn_connection_tunnel1_phase1_dh_group_numbers       = var.vpn_connection_tunnel1_phase1_dh_group_numbers
  vpn_connection_tunnel1_phase2_encryption_algorithms  = var.vpn_connection_tunnel1_phase2_encryption_algorithms
  vpn_connection_tunnel1_phase2_integrity_algorithms   = var.vpn_connection_tunnel1_phase2_integrity_algorithms
  vpn_connection_tunnel1_phase2_dh_group_numbers       = var.vpn_connection_tunnel1_phase2_dh_group_numbers
  vpn_connection_tunnel1_phase_1_lifetime              = var.vpn_connection_tunnel1_phase_1_lifetime
  vpn_connection_tunnel1_phase_2_lifetime              = var.vpn_connection_tunnel1_phase_2_lifetime
  vpn_connection_tunnel1_preshared_key                 = var.vpn_connection_tunnel1_preshared_key
  
  vpn_connection_tunnel2_ike_versions                  = var.vpn_connection_tunnel2_ike_versions 
  vpn_connection_tunnel2_phase1_encryption_algorithms  = var.vpn_connection_tunnel1_phase1_encryption_algorithms
  vpn_connection_tunnel2_phase1_integrity_algorithms   = var.vpn_connection_tunnel1_phase1_integrity_algorithms
  vpn_connection_tunnel2_phase1_dh_group_numbers       = var.vpn_connection_tunnel1_phase1_dh_group_numbers
  vpn_connection_tunnel2_phase2_encryption_algorithms  = var.vpn_connection_tunnel1_phase2_encryption_algorithms
  vpn_connection_tunnel2_phase2_integrity_algorithms   = var.vpn_connection_tunnel1_phase2_integrity_algorithms
  vpn_connection_tunnel2_phase2_dh_group_numbers       = var.vpn_connection_tunnel1_phase2_dh_group_numbers
  vpn_connection_tunnel2_phase_1_lifetime              = var.vpn_connection_tunnel1_phase_1_lifetime
  vpn_connection_tunnel2_phase_2_lifetime              = var.vpn_connection_tunnel1_phase_2_lifetime
  vpn_connection_tunnel2_preshared_key                 = var.vpn_connection_tunnel2_preshared_key

  vpn_connection_rekey_margin_time                     = var.vpn_connection_rekey_margin_time
  vpn_connection_rekey_fuzz                            = var.vpn_connection_rekey_fuzz
  vpn_connection_replay_window                         = var.vpn_connection_replay_window
  vpn_connection_dead_peer_detection                   = var.vpn_connection_dead_peer_detection
  vpn_route_table_private                              = module.vpc.private_route_table_ids[0]
  vpn_route_table_public                               = module.vpc.public_route_table_ids[0]

  providers = {
    aws = aws.main_resource
  }

}


##################################################################
# Backup resources 
##################################################################

provider "aws" {
  
  alias = "backup_resource"

  default_tags {
    tags = {
      Project     = var.name
      Subsystem   = "cloudRelay"
      Environment = var.env
      Deployment  = "terraform"
      Costcenter  = 135
      Team        = "PSi"
    }
  }

  region   = var.aws_region_b
  profile  = var.aws_profile
}

locals {
  format_stage_b = split("-", var.aws_region_b)
  stage_name_b   = "${local.format_stage_b[0]}${local.format_stage_b[1]}-${var.env}"
}

module "vpc_b" {
  source  = "terraform-aws-modules/vpc/aws"
  #version = "4.0.2"

  name = "cr-vpc-${var.name}-${var.env}"
  cidr = var.cidr

  azs             = var.azs_b
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway         = var.enable_nat_gateway
  single_nat_gateway         = var.single_nat_gateway
  one_nat_gateway_per_az     = var.one_nat_gateway_per_az
  manage_default_network_acl = var.manage_default_network_acl
  enable_dns_hostnames       = var.enable_dns_hostnames
  enable_dns_support         = var.enable_dns_support

  providers = {
    aws = aws.backup_resource
  }

}

module "lambda_b" {
  source = "../lambda"
  count  = var.enable_lambda_build ? 1 : 0

  name                        = var.name
  env                         = var.env
  cidr                        = var.cidr
  vpc_id                      = module.vpc_b.vpc_id
  stage_name                  = local.stage_name_b
  aws_region                  = var.aws_region_b
  format_stage                = local.format_stage_b
  private_subnets             = module.vpc_b.private_subnets
  relay_package_location      = var.relay_package_location
  authorizer_package_location = var.authorizer_package_location
  sendcertificate             = var.sendcertificate
  certificatepath             = var.certificatepath
  certificatepassphrase       = var.certificatepassphrase
  certificatekeypath          = var.certificatekeypath
  auth_extra_variables        = var.auth_extra_variables
  relay_extra_variables       = var.relay_extra_variables

  providers = {
    aws = aws.backup_resource
  }

}

module "api_gateway_b" {
  source = "../api_gateway"
  count  = var.enable_lambda_build && var.enable_api_gateway ? 1 : 0
  
  env                           = var.env
  name                          = var.name
  aws_region                    = var.aws_region_b
  stage_name                    = local.stage_name_b
  domain_name                   = var.env == "production" ? "backup-cloudrelay.ps.ringcentral.com" : var.env == "dev" ? "backup-dev.ringcentralps.com" : "staging-backup-cloudrelay.ps.ringcentral.com"
  quota_settings_limit          = var.quota_settings_limit
  quota_settings_offset         = var.quota_settings_offset
  quota_settings_period         = var.quota_settings_period
  throttle_settings_burst_limit = var.throttle_settings_burst_limit
  throttle_settings_rate_limit  = var.throttle_settings_rate_limit

  authorizer_lambda_function = module.lambda_b.0.authorizer_lambda_function.invoke_arn
  relay_lambda_function      = module.lambda_b.0.relay_lambda_function.invoke_arn

  providers = {
    aws = aws.backup_resource
  }

}

resource "aws_vpn_gateway" "vpn_gateway_b" {
  count  = var.enable_vpn_build ? 1 : 0
  vpc_id          = module.vpc_b.vpc_id
  amazon_side_asn = 64512
  
  tags = {
    Name = "cr-vpg-${var.name}-${var.env}"
  }

  provider = aws.backup_resource

}

module "vpn_b" {
  source = "../vpn"
  count  = var.enable_vpn_build ? length(var.customer_gateway_ip_address) : 0

  name                                      = "${var.name}-${count.index}-${var.env}"
  env                                       = var.env
  vpc_id                                    = module.vpc_b.vpc_id
  route_table_ids                           = var.route_table_ids
  aws_vpn_gateway                           = aws_vpn_gateway.vpn_gateway_b.0.id
  customer_gateway_ip_address               = var.customer_gateway_ip_address[count.index]
  vpn_connection_static_routes_destinations = var.vpn_connection_static_routes_destinations
  vpn_connection_local_ipv4_network_cidr    = var.vpn_connection_local_ipv4_network_cidr == "none" ? replace(var.private_subnets[0], "/28", "/26") : var.vpn_connection_local_ipv4_network_cidr
  vpn_connection_remote_ipv4_network_cidr   = var.vpn_connection_remote_ipv4_network_cidr == "none" ? var.vpn_connection_static_routes_destinations[0] : var.vpn_connection_remote_ipv4_network_cidr
  vpn_connection_startup_action             = var.vpn_connection_startup_action
  dpd_timeout_action                        = var.dpd_timeout_action
  vpn_customer_gateway_bgp_asn              = var.vpn_customer_gateway_bgp_asn
  vpn_connection_static_routes_only         = var.vpn_connection_static_routes_only

  vpn_connection_tunnel1_phase1_encryption_algorithms  = var.vpn_connection_tunnel1_phase1_encryption_algorithms
  vpn_connection_tunnel1_phase1_integrity_algorithms   = var.vpn_connection_tunnel1_phase1_integrity_algorithms
  vpn_connection_tunnel1_phase1_dh_group_numbers       = var.vpn_connection_tunnel1_phase1_dh_group_numbers
  vpn_connection_tunnel1_phase2_encryption_algorithms  = var.vpn_connection_tunnel1_phase2_encryption_algorithms
  vpn_connection_tunnel1_phase2_integrity_algorithms   = var.vpn_connection_tunnel1_phase2_integrity_algorithms
  vpn_connection_tunnel1_phase2_dh_group_numbers       = var.vpn_connection_tunnel1_phase2_dh_group_numbers
  vpn_connection_tunnel1_phase_1_lifetime              = var.vpn_connection_tunnel1_phase_1_lifetime
  vpn_connection_tunnel1_phase_2_lifetime              = var.vpn_connection_tunnel1_phase_2_lifetime
  vpn_connection_tunnel1_preshared_key                 = var.vpn_connection_tunnel1_preshared_key
  
  vpn_connection_tunnel2_phase1_encryption_algorithms  = var.vpn_connection_tunnel1_phase1_encryption_algorithms
  vpn_connection_tunnel2_phase1_integrity_algorithms   = var.vpn_connection_tunnel1_phase1_integrity_algorithms
  vpn_connection_tunnel2_phase1_dh_group_numbers       = var.vpn_connection_tunnel1_phase1_dh_group_numbers
  vpn_connection_tunnel2_phase2_encryption_algorithms  = var.vpn_connection_tunnel1_phase2_encryption_algorithms
  vpn_connection_tunnel2_phase2_integrity_algorithms   = var.vpn_connection_tunnel1_phase2_integrity_algorithms
  vpn_connection_tunnel2_phase2_dh_group_numbers       = var.vpn_connection_tunnel1_phase2_dh_group_numbers
  vpn_connection_tunnel2_phase_1_lifetime              = var.vpn_connection_tunnel1_phase_1_lifetime
  vpn_connection_tunnel2_phase_2_lifetime              = var.vpn_connection_tunnel1_phase_2_lifetime
  vpn_connection_tunnel2_preshared_key                 = var.vpn_connection_tunnel2_preshared_key

  vpn_connection_rekey_margin_time                     = var.vpn_connection_rekey_margin_time
  vpn_connection_rekey_fuzz                            = var.vpn_connection_rekey_fuzz
  vpn_connection_replay_window                         = var.vpn_connection_replay_window
  vpn_connection_dead_peer_detection                   = var.vpn_connection_dead_peer_detection
  vpn_route_table_private                              = module.vpc_b.private_route_table_ids[0]
  vpn_route_table_public                               = module.vpc_b.public_route_table_ids[0]

  providers = {
    aws = aws.backup_resource
  }

}

