locals {
  ## The current AWS account ID
  account_id = data.aws_caller_identity.current.account_id
  ## The current AWS region
  region = data.aws_region.current.region
  ## The tags to apply to all resources
  tags = merge(var.tags, { Provisioner = "Terraform" })
  ## Find the vpc id from the subnets
  vpc_id = data.aws_vpc.current.id
  ## AWS Root user ARN
  root_user_arn = format("arn:aws:iam::%s:root", local.account_id)
  ## The cluster configuration, decoded from the YAML file
  cluster = yamldecode(file(var.cluster_path))
  ## The cluster_name of the cluster
  cluster_name = local.cluster.cluster_name
  ## The cluster type
  cluster_type = local.cluster.cluster_type
  ## The platform repository
  platform_repository = local.cluster.platform_repository
  ## The platform revision
  platform_revision = local.cluster.platform_revision
  ## The tenant path
  tenant_path = local.cluster.tenant_path
  ## The tenant repository
  tenant_repository = local.cluster.tenant_repository
  ## The tenant revision
  tenant_revision = local.cluster.tenant_revision
}
