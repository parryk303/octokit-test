variable "name" {
  description = "Name of the project"
  type        = string
}

variable "env" {
  description = "Set enviroment"
  type        = string
}

variable "stage_name" {
  description = "Set stage_name"
  type        = string
}

variable "domain_name" {
  description = "Set domain_name"
  type        = string
}

variable "aws_region" {
  description = "Set AWS region"
  type        = string
  default     = "us-east-2"
}

variable "quota_settings_limit" {
  description = "Set quota_settings_limit"
  type        = string
}

variable "quota_settings_offset" {
  description = "Set quota_settings_offset"
  type        = string
}

variable "quota_settings_period" {
  description = "Set quota_settings_period"
  type        = string
}

variable "throttle_settings_burst_limit" {
  description = "Set throttle_settings_burst_limit"
  type        = string
}

variable "throttle_settings_rate_limit" {
  description = "Set throttle_settings_rate_limit"
  type        = string
}

variable "authorizer_lambda_function" {
  description = "Set authorizer_lambda_function"
  type        = string
}

variable "relay_lambda_function" {
  description = "Set relay_lambda_function"
  type        = string
}
