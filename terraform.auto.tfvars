org     = "greg"
env     = "demo"
project = "route53-sharing"
aws_region = "us-west-2"

vpc_hosting_primary_cidr_block = "10.122.0.0/16"
vpc_hosting_primary_azs = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
vpc_hosting_primary_public_subnet_cidr_blocks = [ "10.122.0.0/24", "10.122.1.0/24", "10.122.2.0/24" ]
vpc_hosting_primary_intra_subnet_cidr_blocks = [ "10.122.16.0/20", "10.122.32.0/20", "10.122.48.0/20" ]
private_hosting_zone_primary = "c.gregoaws.net"

vpc_hosting_secondary_cidr_block = "10.123.0.0/16"
vpc_hosting_secondary_azs = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
vpc_hosting_secondary_public_subnet_cidr_blocks = [ "10.123.0.0/24", "10.123.1.0/24", "10.123.2.0/24" ]
vpc_hosting_secondary_intra_subnet_cidr_blocks = [ "10.123.16.0/20", "10.123.32.0/20", "10.123.48.0/20" ]
private_hosting_zone_secondary = "d.gregoaws.net"

vpc_transit_cidr_block = "100.64.2.0/23"
vpc_transit_azs = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
vpc_transit_public_subnet_cidr_blocks = [ "100.64.2.0/26", "100.64.2.64/26", "100.64.2.128/26" ]
vpc_transit_private_subnet_cidr_blocks = [ "100.64.3.0/26", "100.64.3.64/26", "100.64.3.128/26" ]

tgw_bgp_asn = 65002
