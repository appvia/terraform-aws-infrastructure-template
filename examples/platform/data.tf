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
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}
