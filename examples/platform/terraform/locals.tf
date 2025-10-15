locals {
  ## The current AWS account ID
  account_id = data.aws_caller_identity.current.account_id
  # The current region
  region = data.aws_region.current.region
  ## AWS Root user ARN
  root_account_arn = format("arn:aws:iam::%s:root", local.account_id)
  ## The tags to apply to all resources
  tags = merge(var.tags, { Provisioner = "Terraform" })
  ## The default description of the tenant repository if none is provided
  tenant_repository_default_description = format("Application definitions for the %s cluster.", var.cluster_name)
  ## The description of the tenant repository
  tenant_repository_description = try(var.tenant_repository.description, null) == null ? local.tenant_repository_default_description : try(var.tenant_repository.description, null)
  ## Find the vpc id from the subnets
  vpc_id = var.vpc_name != null ? try(data.aws_vpc.current[0].id, null) : module.network[0].vpc_id
  ## The private subnet ids to use for the cluster
  private_subnet_ids = var.vpc_name != null ? try(data.aws_subnets.private_subnets.ids, null) : try(module.network[0].private_subnet_ids, null)
  ## We use the transit gateway ID passed into the module if provided, otherwise we use the regional transit gateway
  transit_gateway_id = var.transit_gateway_id != null ? var.transit_gateway_id : data.aws_ec2_transit_gateway.current.id
  ## Should we create the tenant repository
  create_tenant_repository = var.tenant_repository != null ? try(var.tenant_repository.create, false) : false
  ## The IPAM pool ID if the ipam pool name is provided
  ipam_pool_id = var.ipam_pool_name != null ? try(data.aws_vpc_ipam_pool.current[0].id, null) : null
  ## The tenant repository URL 
  tenant_repository_url = var.tenant_repository != null ? var.tenant_repository.repository : "https://github.com/appvia/terraform-aws-infrastructure-template"
  ## The tenant repository path 
  tenant_repository_path = var.tenant_repository != null ? var.tenant_repository.path : "examples/platform/release"
}
