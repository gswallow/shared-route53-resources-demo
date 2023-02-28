########################################
# Globals
########################################
variable "aws_region" {
  type        = string
  description = "The AWS region in which to create resources"
  default     = "us-east-1"
}

variable "env" {
  type        = string
  description = "The name of the environment, for use in AWS resource tags"
  default     = "dev"
}

variable "org" {
  type        = string
  description = "The name of the organization hosting the AWS resources, for use in resource tags"
  default     = "GregOnAWS"
}

variable "project" {
  type        = string
  description = "The name of the project served by these AWS resources, for use in resource tags"
  default     = "vaultdemo"
}

variable "tags" {
  type        = map(string)
  description = "A key/value map of additional resource tags to apply to AWS resources"
  default     = {}
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in each VPC"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support in each VPC"
  default     = true
}

variable "internal_cidr_blocks" {
  type        = list(string)
  description = "The CIDR block of all internal networks routed from the transit network to hosting VPCs"
  default     = ["10.0.0.0/8"]
}

########################################
# Hosting VPC A
########################################
variable "vpc_hosting_a_cidr_block" {
  type        = string
  description = "The CIDR block of Hosting VPC A"
  default     = "10.120.0.0/16"
}

variable "vpc_hosting_a_azs" {
  type        = list(string)
  description = "The list of AZs in which to create subnets"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_hosting_a_public_subnet_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks to apply to each subnet"
  default     = ["10.120.0.0/24", "10.120.1.0/24", "10.120.2.0/24"]
}

variable "vpc_hosting_a_intra_subnet_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks to apply to each subnet"
  default     = ["10.120.16.0/20", "10.120.32.0/20", "10.120.48.0/20"]
}

variable "private_hosted_zone_a" {
  type        = string
  description = "The private hosted zone to use with VPC A"
  default     = "a.gregonaws.net"
}

########################################
# Hosting VPC B
########################################
variable "vpc_hosting_b_cidr_block" {
  type        = string
  description = "The CIDR block of Hosting VPC A"
  default     = "10.121.0.0/16"
}

variable "vpc_hosting_b_azs" {
  type        = list(string)
  description = "The list of AZs in which to create subnets"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_hosting_b_public_subnet_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks to apply to each subnet"
  default     = ["10.121.0.0/24", "10.121.1.0/24", "10.121.2.0/24"]
}

variable "vpc_hosting_b_intra_subnet_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks to apply to each subnet"
  default     = ["10.121.16.0/20", "10.121.32.0/20", "10.121.48.0/20"]
}

variable "private_hosted_zone_b" {
  type        = string
  description = "The private hosted zone to use with VPC B"
  default     = "b.gregonaws.net"
}

########################################
# Transit VPC A
########################################
variable "vpc_transit_cidr_block" {
  type        = string
  description = "The CIDR block of Transit VPC A"
  default     = "100.64.0.0/23"
}

variable "vpc_transit_azs" {
  type        = list(string)
  description = "The list of AZs in which to create subnets"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_transit_public_subnet_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks to apply to each subnet"
  default     = ["100.64.0.0/26", "100.64.0.64/26", "100.64.0.128/26"]
}

variable "vpc_transit_private_subnet_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks to apply to each subnet"
  default     = ["100.64.1.0/26", "100.64.1.64/26", "100.64.1.128/26"]
}

########################################
# Transit Gateways
########################################
variable "auto_accept_shared_tgw_attachments" {
  description = "Automatically accept target gateway attachment requests"
  type        = string
  default     = "enable" # Must be "enable" or "disable"
}

variable "tgw_bgp_asn" {
  description = "The BGP Autonomous System Number for this transit gateway, for connection to other VPN gateways"
  type        = number
  default     = 65001
}

########################################
# Locals
########################################
locals {
  prefix = replace(lower("${var.org}-${var.env}-${var.project}"), "_", "-")
  tags = merge({
    "Organization:environment" = var.env,
    "Organization:name"        = var.org,
    "Organization:project"     = var.project,
  }, var.tags)
}
