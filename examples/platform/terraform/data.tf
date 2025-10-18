# Find the current AWS account ID
data "aws_caller_identity" "current" {}

# Find all subnets in the VPC, with the tag "Tier" set to "Private"
data "aws_subnets" "private_subnets" {
  tags = {
    tier = "private"
  }
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

# Find the VPC by name
data "aws_vpc" "current" {
  count = var.vpc_name != null ? 1 : 0

  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

## Find the regional transit gateway
data "aws_ec2_transit_gateway" "current" {
  filter {
    name   = "state"
    values = ["available"]
  }
}

## Find the IPAM pool by description
data "aws_vpc_ipam_pool" "current" {
  count = var.ipam_pool_name != null ? 1 : 0

  filter {
    name   = "description"
    values = [var.ipam_pool_name]
  }
}
