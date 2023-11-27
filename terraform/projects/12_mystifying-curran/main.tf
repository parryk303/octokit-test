
  module "cloud_relay" {
    source              = "../../module/main"
    name                = "12_mystifying-curran"
    env                 = var.env
    cidr                = "Input is not an array"
    private_subnets     = Input is not an array
    public_subnets      = [""]

    relay_package_location      = "lambdas_code/relay-lambda-code.zip"
    authorizer_package_location = "lambdas_code/authorizer-lambda-code.zip"

    enable_vpn_build = false
}

