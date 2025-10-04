locals {
  ## The current AWS account ID
  account_id = data.aws_caller_identity.current.account_id
  ## The current AWS region
  region = data.aws_region.current.region
  ## The tags to apply to all resources
  tags = merge(var.tags, { Provisioner = "Terraform" })
  ## Find the vpc id from the subnets
  vpc_id = try(data.aws_subnets.private_subnets.0.vpc_id, null)
}
