##################################################################
# Objects needed for lambda function
##################################################################
locals {
  lambda_execution_role_name = "cr-lambda_execution_role-${var.name}-${var.env}-${var.aws_region}"
}
resource "random_id" "api" {
  byte_length = 32
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "rc-cr-s3-upload-relay-lambda-${substr(random_id.api.dec, 0, 5)}"
  force_destroy = true
}

# resource "aws_s3_bucket_acl" "lambda_bucket_acl" {
#   bucket = aws_s3_bucket.lambda_bucket.id
#   acl    = "private"
# }

resource "aws_security_group" "api" {
  name_prefix = "SG Lambda function for ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow all from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.cidr]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}



##################################################################
# Build extension layer
####################################################

data "aws_lambda_layer_version" "extension" {
  layer_name  = var.aws_region == "us-east-2" ? "arn:aws:lambda:us-east-2:590474943231:layer:AWS-Parameters-and-Secrets-Lambda-Extension" : "arn:aws:lambda:us-west-2:345057560386:layer:AWS-Parameters-and-Secrets-Lambda-Extension"
  version    = 2
}



##################################################################
# Build relay lambda function
##################################################################

resource "aws_s3_object" "relay_lambda_code" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "rc-cr-s3-upload-relay-lambda-${var.name}-${var.env}.zip"
  source = var.relay_package_location
  etag   = filemd5(var.relay_package_location)
}

resource "aws_iam_role" "lambda_execution_role" {

  name = local.lambda_execution_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["sts:AssumeRole"]
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })

  inline_policy {
    name = "allow_vpc"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstances",
          "ec2:AttachNetworkInterface"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  inline_policy {
    name = "allow_lambda_edit"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
              "secretsmanager:GetSecretValue",
              "secretsmanager:DescribeSecret",
              "secretsmanager:ListSecretVersionIds",
              "secretsmanager:PutSecretValue",
              "secretsmanager:UpdateSecret",
              "secretsmanager:TagResource",
              "secretsmanager:UntagResource"
            ],
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

}

resource "aws_lambda_function" "relay_lambda_function" {

  depends_on = [
    aws_iam_role.lambda_execution_role
  ]
  
  function_name    = "${var.format_stage[0]}${var.format_stage[1]}-${var.env}-Relay-${var.name}"
  description      = "relay Lambda function for ${var.name}"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.relay_lambda_code.key
  runtime          = "nodejs14.x"
  handler          = "index.handler"
  role             = aws_iam_role.lambda_execution_role.arn
  layers           = [data.aws_lambda_layer_version.extension.arn]

  vpc_config {
    subnet_ids         = [var.private_subnets[0], var.private_subnets[1]]
    security_group_ids = [aws_security_group.api.id]
  }
  environment {
    variables = merge ( {
      CUSTOMER              = lower(var.name)
      REGION                = var.aws_region
      STAGE                 = var.stage_name
    }, var.relay_extra_variables )
  }
}

resource "aws_cloudwatch_log_group" "relay_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.relay_lambda_function.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role_policy_attachment" "relay_lambda_policy" {

  depends_on = [
    aws_iam_role.lambda_execution_role
  ]

  count = var.aws_region == "us-east-2" ? 1 : 0

  role       = aws_iam_role.lambda_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "relay_api_gateway_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.relay_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
}



##################################################################
# Build Authorizer lambda function
##################################################################

resource "aws_s3_object" "authorizer_lambda_code" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "rc-cr-s3-upload-authorizer-lambda-${var.name}.zip"
  source = var.authorizer_package_location
  etag   = filemd5(var.authorizer_package_location)
}

resource "aws_lambda_function" "authorizer_lambda_function" {

  depends_on = [
    aws_iam_role.lambda_execution_role
  ]

  function_name    = "${var.format_stage[0]}${var.format_stage[1]}-${var.env}-Authorizer-${var.name}"
  description      = "authorizer Lambda function for ${var.name}"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.authorizer_lambda_code.key
  runtime          = "nodejs14.x"
  handler          = "index.handler"
  role             = aws_iam_role.lambda_execution_role.arn
  layers           = [data.aws_lambda_layer_version.extension.arn]

  vpc_config {
    subnet_ids         = [var.private_subnets[0], var.private_subnets[1]]
    security_group_ids = [aws_security_group.api.id]
  }
  environment {
    variables = merge ( {
      CUSTOMER = lower(var.name)
    }, var.auth_extra_variables )
  }
}

resource "aws_cloudwatch_log_group" "authorizer_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.authorizer_lambda_function.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role_policy_attachment" "authorizer_lambda_policy" {

  depends_on = [
    aws_iam_role.lambda_execution_role
  ]

  count = var.aws_region == "us-east-2" ? 1 : 0 
  
  role       = aws_iam_role.lambda_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "authorizer_api_gateway_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
}

### Destroy S3 bucket used to upload Lambda functions

resource "null_resource" "delete_lambda_S3" {
  depends_on = [
    aws_lambda_function.relay_lambda_function,
    aws_lambda_function.authorizer_lambda_function
  ]
  provisioner "local-exec" {
    command = "aws s3 rb s3://${aws_s3_bucket.lambda_bucket.id} --force"
  }
}