
  module "cloud_relay" {
    source              = "../../module/main"
    name                = "1234_infallible-keller"
    env                 = var.env
    cidr                = "[&#34;172.31.0.0/28&#34;]"
    private_subnets     = Input is not an array
    public_subnets      = [""]

    relay_package_location      = "lambdas_code/relay-lambda-code.zip"
    authorizer_package_location = "lambdas_code/authorizer-lambda-code.zip"

    enable_vpn_build = false
}

