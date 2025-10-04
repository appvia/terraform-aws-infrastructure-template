# Find the current AWS account ID
data "aws_caller_identity" "current" {}

# Find the current AWS region
data "aws_region" "current" {}

# Find all subnets in the VPC, with the tag "Tier" set to "Private"
data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.current.id]
  }
  tags = {
    tier = "private"
  }
}
