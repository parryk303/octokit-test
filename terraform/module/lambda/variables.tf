variable "name" {
  description = "Name of the project"
  type        = string
}

variable "relay_extra_variables" {
  description = "Add extra relay enviroment variables"
  type        = map(string)
}

variable "auth_extra_variables" {
  description = "Add extra auth enviroment variables"
  type        = map(string)
}

variable "stage_name" {
  description = "Set stage_name"
  type        = string
}

variable "env" {
  description = "Set enviroment"
  type        = string
}

variable "format_stage" {
  description = "Set format_stage"
  type        = list(string)
}

variable "cidr" {
  description = "Set cidr"
  type        = string
}

variable "vpc_id" {
  description = "Set vpc_id"
  type        = string
}

variable "private_subnets" {
  description = "Set private_subnets"
  type        = list(string)
}

variable "aws_region" {
  description = "Set AWS region"
  type        = string
}

variable "relay_package_location" {
  description = "Package path for the lambda content"
  type        = string
}

variable "authorizer_package_location" {
  description = "Package path for the lambda content"
  type        = string
}

variable "sendcertificate" {
  description = "Lambda variable"
  type        = string
}

variable "certificatepath" {
  description = "Lambda variable"
  type        = string
}

variable "certificatepassphrase" {
  description = "Lambda variable"
  type        = string
}

variable "certificatekeypath" {
  description = "Lambda variable"
  type        = string
}