locals {
  ## The current AWS account ID
  account_id = data.aws_caller_identity.current.account_id
  ## AWS Root user ARN
  root_account_arn = format("arn:aws:iam::%s:root", local.account_id)
  ## The tags to apply to all resources
  tags = merge(var.tags, { Provisioner = "Terraform" })
  ## The default description of the tenant repository if none is provided
  tenant_repository_default_description = format("Application definitions for the %s cluster.", var.cluster_name)
  ## The description of the tenant repository
  tenant_repository_description = var.tenant_repository.description == null ? local.tenant_repository_default_description : var.tenant_repository.description
  ## Find the vpc id from the subnets
  vpc_id = data.aws_vpc.current.id
  ## We use the transit gateway ID passed into the module if provided, otherwise we use the regional transit gateway
  transit_gateway_id = var.transit_gateway_id != null ? var.transit_gateway_id : data.aws_ec2_transit_gateway.current.id
  ## Should we create the tenant repository
  create_tenant_repository = var.tenant_repository != null ? try(var.tenant_repository.create, false) : true
  ## The IPAM pool ID if the ipam pool name is provided
  ipam_pool_id = var.ipam_pool_name != null ? try(data.aws_vpc_ipam_pool.current[0].id, null) : null
  ## The tenant repository URL 
  tenant_repository_url = var.tenant_repository != null ? var.tenant_repository.repository : "https://github.com/appvia/terraform-aws-infrastructure-template"
  ## The tenant repository path 
  tenant_repository_path = var.tenant_repository != null ? var.tenant_repository.path : "examples/platform/release"
}
