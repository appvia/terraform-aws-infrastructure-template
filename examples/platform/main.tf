
#
## Provision a Container Platform
#
# Uncomment the following resources to provision a container platform (EKS) if you 
# are using the Platform pattern: https://github.com/appvia/kubernetes-platform
#

## Provision a repository used to store the application workloads definitions
module "workloads" {
  source  = "appvia/repository/github"
  version = "0.0.1"

  name           = "workloads"
  description    = "Application workloads repository for the platform"
  visibility     = "private"
  default_branch = "main"
  create         = true # Set to false if you want to use an existing repository

  branch_protection = {
    dismiss_stale_reviews                = true
    enforce_branch_protection_for_admins = true
    prevent_self_review                  = true
    required_approving_review_count      = 2
  }

  template = {
    owner      = "appvia"
    repository = "kubernetes-platform-workloads-template"
  }
}

## Provision an EKS container platform to deploy workloads
module "eks" {
  source  = "appvia/eks/aws"
  version = "0.0.1"

  access_entries         = var.access_entries
  cluster_name           = var.cluster_name
  cluster_version        = var.cluster_version
  kms_key_administrators = [module.kms_administrator.iam_role_arn]
  private_subnet_ids     = data.aws_subnets.private_subnets.ids
  tags                   = local.tags
  vpc_id                 = data.aws_vpc.current.id
}
