
  module "cloud_relay" {
    source              = "../../module/main"
    name                = "LAUGHINGBENZ"
    env                 = var.env
    cidr                = "172.31.0.0/28"
    private_subnets     = ["192.168.0.0/28", "192.168.0.16/28"]
    public_subnets      = ["192.168.0.32/27"]

    relay_package_location      = "lambdas_code/relay-lambda-code.zip"
    authorizer_package_location = "lambdas_code/authorizer-lambda-code.zip"

    enable_vpn_build = false
}

