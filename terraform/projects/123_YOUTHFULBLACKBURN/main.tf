
  module "cloud_relay" {
    source              = "../../module/main"
    name                = "YOUTHFULBLACKBURN"
    env                 = var.env
    cidr                = "10.1.0.0/28"
    private_subnets     = ["10.1.0.0/28", "10.1.0.16/28"]
    public_subnets      = ["10.1.0.0.32/27"]

    relay_package_location      = "lambdas_code/relay-lambda-code.zip"
    authorizer_package_location = "lambdas_code/authorizer-lambda-code.zip"

    enable_vpn_build = false
}

