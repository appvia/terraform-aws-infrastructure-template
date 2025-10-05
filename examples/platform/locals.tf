locals {
  ## The current AWS account ID
  account_id = data.aws_caller_identity.current.account_id
  ## AWS Root user ARN
  root_user_arn = format("arn:aws:iam::%s:root", local.account_id)
  ## The tags to apply to all resources
  tags = merge(var.tags, { Provisioner = "Terraform" })
  ## The default description of the tenant repository if none is provided
  tenant_repository_default_description = format("Application definitions for the %s cluster.", var.cluster_name)
  ## The description of the tenant repository
  tenant_repository_description = var.tenant_repository.description == null ? local.tenant_repository_default_description : var.tenant_repository.description
  ## Find the vpc id from the subnets
  vpc_id = data.aws_vpc.current.id
}
