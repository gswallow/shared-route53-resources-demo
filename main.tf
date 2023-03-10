########################################
# VPC A
########################################
module "vpc_hosting_primary" {
  source                  = "terraform-aws-modules/vpc/aws"
  version                 = "3.19.0"
  name                    = "${local.prefix}-vpc-hosting-${var.primary_vpc_identifier}"
  cidr                    = var.vpc_hosting_primary_cidr_block
  azs                     = var.vpc_hosting_primary_azs
  public_subnets          = var.vpc_hosting_primary_public_subnet_cidr_blocks
  intra_subnets           = var.vpc_hosting_primary_intra_subnet_cidr_blocks
  enable_nat_gateway      = false
  enable_dns_hostnames    = var.enable_dns_hostnames
  enable_dns_support      = var.enable_dns_support
  igw_tags                = { "Name" = "${local.prefix}-vpc-hosting-${var.primary_vpc_identifier}-igw" }
  intra_route_table_tags  = { "Name" = "${local.prefix}-vpc-hosting-${var.primary_vpc_identifier}-private-rtb" }
  intra_subnet_tags       = { "Tier" = "private" }
  public_route_table_tags = { "Name" = "${local.prefix}-vpc-hosting-${var.primary_vpc_identifier}-public-rtb" }
  public_subnet_tags      = { "Tier" = "public" }
  tags                    = local.tags
}

resource "aws_security_group" "dns_vpc_hosting_primary" {
  name        = "${local.prefix}-dns-sg"
  description = "Allow inbound DNS queries"
  vpc_id      = module.vpc_hosting_primary.vpc_id

  ingress {
    description = "Allow TCP DNS queries"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow UDP DNS queries"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_resolver_rule_association" "default_vpc_hosting_primary" {
  resolver_rule_id = aws_route53_resolver_rule.default_override.id
  vpc_id           = module.vpc_hosting_primary.vpc_id
}

resource "aws_route53_zone" "primary" {
  name = var.private_hosted_zone_primary
  vpc {
    vpc_id = module.vpc_hosting_primary.vpc_id
  }

  lifecycle {
    ignore_changes = ["vpc"]
  }
}

resource "aws_route53_zone_association" "a_to_vpc_transit" {
  zone_id = aws_route53_zone.primary.zone_id
  vpc_id  = module.vpc_transit.vpc_id
}

########################################
# VPC B
########################################
module "vpc_hosting_secondary" {
  source                  = "terraform-aws-modules/vpc/aws"
  version                 = "3.19.0"
  name                    = "${local.prefix}-vpc-hosting-${var.secondary_vpc_identifier}"
  cidr                    = var.vpc_hosting_secondary_cidr_block
  azs                     = var.vpc_hosting_secondary_azs
  public_subnets          = var.vpc_hosting_secondary_public_subnet_cidr_blocks
  intra_subnets           = var.vpc_hosting_secondary_intra_subnet_cidr_blocks
  enable_nat_gateway      = false
  enable_dns_hostnames    = var.enable_dns_hostnames
  enable_dns_support      = var.enable_dns_support
  igw_tags                = { "Name" = "${local.prefix}-vpc-hosting-${var.secondary_vpc_identifier}-igw" }
  intra_route_table_tags  = { "Name" = "${local.prefix}-vpc-hosting-${var.secondary_vpc_identifier}-private-rtb" }
  intra_subnet_tags       = { "Tier" = "private" }
  public_route_table_tags = { "Name" = "${local.prefix}-vpc-hosting-${var.secondary_vpc_identifier}-public-rtb" }
  public_subnet_tags      = { "Tier" = "public" }
  tags                    = local.tags
}

resource "aws_security_group" "dns_vpc_hosting_secondary" {
  name        = "${local.prefix}-dns-sg"
  description = "Allow inbound DNS queries"
  vpc_id      = module.vpc_hosting_secondary.vpc_id

  ingress {
    description = "Allow TCP DNS queries"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow UDP DNS queries"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_resolver_rule_association" "default_vpc_hosting_secondary" {
  resolver_rule_id = aws_route53_resolver_rule.default_override.id
  vpc_id           = module.vpc_hosting_secondary.vpc_id
}

resource "aws_route53_zone" "secondary" {
  name = var.private_hosted_zone_secondary
  vpc {
    vpc_id = module.vpc_hosting_secondary.vpc_id
  }

  lifecycle {
    ignore_changes = ["vpc"]
  }
}

resource "aws_route53_zone_association" "b_to_vpc_transit" {
  zone_id = aws_route53_zone.secondary.zone_id
  vpc_id  = module.vpc_transit.vpc_id
}

########################################
# Transit VPC
########################################
module "vpc_transit" {
  source                   = "terraform-aws-modules/vpc/aws"
  version                  = "3.19.0"
  name                     = "${local.prefix}-vpc-${var.transit_vpc_identifier}"
  cidr                     = var.vpc_transit_cidr_block
  azs                      = var.vpc_transit_azs
  public_subnets           = var.vpc_transit_public_subnet_cidr_blocks
  private_subnets          = var.vpc_transit_private_subnet_cidr_blocks
  enable_nat_gateway       = true
  single_nat_gateway       = false
  enable_dns_hostnames     = var.enable_dns_hostnames
  enable_dns_support       = var.enable_dns_support
  igw_tags                 = { "Name" = "${local.prefix}-vpc-${var.transit_vpc_identifier}-igw" }
  nat_eip_tags             = { "Name" = "${local.prefix}-vpc-${var.transit_vpc_identifier}-nat-eip" }
  nat_gateway_tags         = { "Name" = "${local.prefix}-vpc-${var.transit_vpc_identifier}-natgw" }
  private_route_table_tags = { "Name" = "${local.prefix}-vpc-${var.transit_vpc_identifier}-private-rtb" }
  private_subnet_tags      = { "Tier" = "private" }
  public_route_table_tags  = { "Name" = "${local.prefix}-vpc-${var.transit_vpc_identifier}-public-rtb" }
  public_subnet_tags       = { "Tier" = "public" }
  tags                     = local.tags
}

resource "aws_security_group" "dns_vpc_transit" {
  name        = "${local.prefix}-dns-sg"
  description = "Allow inbound DNS queries"
  vpc_id      = module.vpc_transit.vpc_id

  ingress {
    description = "Allow TCP DNS queries"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow UDP DNS queries"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_resolver_endpoint" "transit_inbound" {
  name               = "${local.prefix}-${var.transit_vpc_identifier}-resolver-inbound"
  direction          = "INBOUND"
  security_group_ids = [aws_security_group.dns_vpc_transit.id]

  ip_address {
    subnet_id = module.vpc_transit.private_subnets[0]
    ip        = cidrhost(module.vpc_transit.private_subnets_cidr_blocks[0], 6)
  }

  ip_address {
    subnet_id = module.vpc_transit.private_subnets[1]
    ip        = cidrhost(module.vpc_transit.private_subnets_cidr_blocks[1], 6)
  }

  ip_address {
    subnet_id = module.vpc_transit.private_subnets[2]
    ip        = cidrhost(module.vpc_transit.private_subnets_cidr_blocks[2], 6)
  }
}

resource "aws_route53_resolver_endpoint" "vpc_transit_outbound" {
  name               = "${local.prefix}-${var.transit_vpc_identifier}-resolver-vpc-${var.secondary_vpc_identifier}-outbound"
  direction          = "OUTBOUND"
  security_group_ids = [aws_security_group.dns_vpc_transit.id]

  ip_address {
    subnet_id = module.vpc_transit.private_subnets[0]
    ip        = cidrhost(module.vpc_transit.private_subnets_cidr_blocks[0], 5)
  }

  ip_address {
    subnet_id = module.vpc_transit.private_subnets[1]
    ip        = cidrhost(module.vpc_transit.private_subnets_cidr_blocks[1], 5)
  }

  ip_address {
    subnet_id = module.vpc_transit.private_subnets[2]
    ip        = cidrhost(module.vpc_transit.private_subnets_cidr_blocks[2], 5)
  }
}

resource "aws_route53_resolver_rule" "default_override" {
  domain_name          = "."
  name                 = "default_override"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.vpc_transit_outbound.id

  target_ip {
    ip = cidrhost(module.vpc_transit.private_subnets_cidr_blocks[0], 6)
  }

  target_ip {
    ip = cidrhost(module.vpc_transit.private_subnets_cidr_blocks[1], 6)
  }

  target_ip {
    ip = cidrhost(module.vpc_transit.private_subnets_cidr_blocks[2], 6)
  }
}

########################################
# Transit Gateway
########################################
resource "aws_ec2_transit_gateway" "tgw" {
  description                    = "Demo TGW"
  amazon_side_asn                = var.tgw_bgp_asn
  auto_accept_shared_attachments = var.auto_accept_shared_tgw_attachments
  tags                           = merge(local.tags, { "Name" = "${local.prefix}-tgw" })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_to_hosting_vpc_hosting_primary" {
  subnet_ids             = module.vpc_hosting_primary.intra_subnets
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  vpc_id                 = module.vpc_hosting_primary.vpc_id
  appliance_mode_support = "enable"
  tags                   = merge(local.tags, { "Name" = "${local.prefix}-tgw-to-hosting-vpc-${var.primary_vpc_identifier}" })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_to_hosting_vpc_transit" {
  subnet_ids             = module.vpc_hosting_secondary.intra_subnets
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  vpc_id                 = module.vpc_hosting_secondary.vpc_id
  appliance_mode_support = "enable"
  tags                   = merge(local.tags, { "Name" = "${local.prefix}-tgw-to-hosting-vpc-${var.secondary_vpc_identifier}" })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_to_transit_vpc" {
  subnet_ids             = module.vpc_transit.private_subnets
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  vpc_id                 = module.vpc_transit.vpc_id
  appliance_mode_support = "enable"
  tags                   = merge(local.tags, { "Name" = "${local.prefix}-tgw-to-${var.transit_vpc_identifier}-vpc" })
}

########################################
# Routes
########################################
resource "aws_route" "default_through_tgw" {
  count                  = length(local.intra_route_table_ids)
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  route_table_id         = element(local.intra_route_table_ids, count.index)
}

resource "aws_route" "private_internal_through_tgw" {
  for_each               = { for route in local.private_subnet_internal_routes : "${route.rtb}.${route.block}" => route }
  destination_cidr_block = each.value.block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  route_table_id         = each.value.rtb
}

resource "aws_route" "public_internal_through_tgw" {
  for_each               = { for route in local.public_subnet_internal_routes : "${route.rtb}.${route.block}" => route }
  destination_cidr_block = each.value.block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  route_table_id         = each.value.rtb
}

resource "aws_ec2_transit_gateway_route" "default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_to_transit_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw.association_default_route_table_id
}

########################################
# Resolver endpoint metrics
########################################
resource "aws_cloudwatch_metric_alarm" "inbound_endpoint_query_volume" {
  count                     = var.monitor_endpoint_query_volume ? 1 : 0
  alarm_name                = "${local.prefix}-route53-inbound-resolver-endpoint-query-volume"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  datapoints_to_alarm       = 1
  metric_name               = "InboundQueryVolume"
  namespace                 = "AWS/Route53Resolver"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 9000
  alarm_description         = "Inbound queries are OVER 9,000!"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  dimensions = {
    "EndpointId"           = aws_route53_resolver_endpoint.transit_inbound.id
  }
}

resource "aws_cloudwatch_metric_alarm" "outbound_endpoint_query_volume" {
  count                     = var.monitor_endpoint_query_volume ? 1 : 0
  alarm_name                = "${local.prefix}-route53-outbound-resolver-endpoint-query-volume"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  datapoints_to_alarm       = 1
  metric_name               = "OutboundQueryAggregateVolume"
  namespace                 = "AWS/Route53Resolver"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 9000
  alarm_description         = "Outbound queries are OVER 9,000!"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  dimensions = {
    "EndpointId"           = aws_route53_resolver_endpoint.vpc_transit_outbound.id
  }
}

########################################
# Locally generated values
########################################
locals {
  vpc_ids               = [for vpc in [module.vpc_hosting_primary, module.vpc_hosting_secondary, module.vpc_transit] : vpc.vpc_id]
  intra_route_table_ids = flatten([for vpc in [module.vpc_hosting_primary, module.vpc_hosting_secondary] : vpc.intra_route_table_ids])
  private_subnet_internal_routes = flatten([for rtb in module.vpc_transit.private_route_table_ids : [
    for block in var.internal_cidr_blocks : {
      rtb   = rtb
      block = block
    }]
  ])
  public_subnet_internal_routes = flatten([for rtb in module.vpc_transit.public_route_table_ids : [
    for block in var.internal_cidr_blocks : {
      rtb   = rtb
      block = block
    }]
  ])
}
