
  module "cloud_relay" {
    source              = "../../module/main"
    name                = "123: vibrant-rosalind"
    env                 = var.env
    cidr                = "Input is not an array"
    private_subnets     = ["172.31.0.0/28", "172.31.0.16/28"]
    public_subnets      = ["172.31.0.32/27"]

    relay_package_location      = "lambdas_code/relay-lambda-code.zip"
    authorizer_package_location = "lambdas_code/authorizer-lambda-code.zip"

    enable_vpn_build = false

}

