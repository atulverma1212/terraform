# TODO: Define the variable for aws_region
variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "lambda_function_name" {
  type    = string
  default = "autorefundHandler"
}

variable "lambda_subnet_ids" {
  type    = list(string)
  default = ["subnet-aa7e0b81","subnet-0189ddb2caa0359ad"]
}

variable "lambda_security_group_ids" {
  type    = list(string)
  default = ["sg-7e6b1839","sg-09b07a139ec3d8a46"]
}

variable "lambda_vpc_id" {
  type    = string
  default = "vpc-b1be06cb"
}

# Environment variables
variable "DBPassword" {}
variable "DBUsername" {}
variable "Server" {}
variable "Port" {}
variable "Database" {}
