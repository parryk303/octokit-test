##################################################################
# Build api gateway
##################################################################

resource "aws_api_gateway_rest_api" "api" {
  name = "cr-api_gateway-${var.name}"
  endpoint_configuration {
    types = ["EDGE"]
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_authorizer" "api" {
  name                             = "auth"
  rest_api_id                      = aws_api_gateway_rest_api.api.id
  authorizer_uri                   = var.authorizer_lambda_function
  identity_source                  = "method.request.header.x-api-secret"
  type                             = "TOKEN"
  authorizer_result_ttl_in_seconds = 0
}

### Proxy

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "CUSTOM"
  api_key_required = true
  authorizer_id = aws_api_gateway_authorizer.api.id
}

resource "aws_api_gateway_integration" "lambda_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.relay_lambda_function
}

### MOCK

resource "aws_api_gateway_method" "mock" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "mock" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.mock.resource_id
  http_method = aws_api_gateway_method.mock.http_method
  type        = "MOCK"

  # Transforms the incoming XML request to JSON
  request_templates = {
    "application/xml" = <<EOF
{
   "body" : $input.json('$')
}
EOF
  }
}

resource "aws_api_gateway_integration_response" "mock" {
  depends_on = [
    aws_api_gateway_rest_api.api,
    aws_api_gateway_resource.proxy,
    aws_api_gateway_integration.mock,
    aws_api_gateway_method.mock
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.mock.http_method
  status_code = "200"

  response_templates = {
    "application/json" = ""
  }
}

### Deployment

resource "aws_api_gateway_deployment" "api" {
  depends_on = [
    aws_api_gateway_integration.lambda_proxy
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.stage_name
}

### Usage plan

resource "aws_api_gateway_usage_plan" "api" {
  name = "cr-usage_plan-${var.name}"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_deployment.api.stage_name
  }

  quota_settings {
    limit  = var.quota_settings_limit
    offset = var.quota_settings_offset
    period = var.quota_settings_period
  }

  throttle_settings {
    burst_limit = var.throttle_settings_burst_limit
    rate_limit  = var.throttle_settings_rate_limit
  }
}

resource "aws_api_gateway_api_key" "api" {
  name = "cr-api_key-${var.name}"
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.api.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api.id
}

### Add Custom Domain name Mapping

resource "aws_api_gateway_base_path_mapping" "api" {

  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_deployment.api.stage_name
  domain_name = var.domain_name 
  base_path   = lower(var.name)
}