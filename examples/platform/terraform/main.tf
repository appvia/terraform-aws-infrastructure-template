
#
## Provision a Container Platform
#
# Uncomment the following resources to provision a container platform (EKS) if you
# are using the Platform pattern: https://github.com/appvia/kubernetes-platform
#

## Provision a repository used to store the application workloads definitions
## Optional - only required if you want the tenant repository to be created in a
## separate repository to infrastructure pipeline
module "tenant_repository" {
  count   = local.create_tenant_repository ? 1 : 0
  source  = "appvia/repository/github"
  version = "1.1.2"

  repository   = basename(try(var.tenant_repository.repository, ""))
  description  = local.tenant_repository_description
  visibility   = try(var.tenant_repository.visibility, "private")
  environments = {}

  # Template settings
  template = try(var.tenant_repository.template, null) != null ? {
    owner      = try(var.tenant_repository.template.owner, null)
    repository = try(var.tenant_repository.template.repository, null)
  } : null

  ## Allow auto merge, merge commit, rebase merge, and squash merge
  allow_auto_merge = true
  # Allow merge commit to be used
  allow_merge_commit = true
  # Allow rebase merge to be used
  allow_rebase_merge = true
  # Allow squash merge to be used
  allow_squash_merge = true
  # Delete the branch on merge
  delete_branch_on_merge = true

  ## Branch protection rules
  branch_protection = {
    main = {
      # Disable force pushes, deletions, and merge commits
      allows_force_pushes = false
      # Disable deletions of the main branch
      allows_deletions = false
      # Require conversation resolution
      require_conversation_resolution = true
      # Require signed commits
      require_signed_commits = true
      # Disable linear history
      required_linear_history = false

      required_status_checks = {
        strict   = true
        contexts = null
      }

      required_pull_request_reviews = {
        require_code_owner_reviews      = false
        require_last_push_approval      = false
        required_approving_review_count = 1
        restrict_dismissals             = false
      }
    }
  }
}

## Provision a network for the cluster
module "network" {
  count   = var.vpc_name == null ? 1 : 0
  source  = "appvia/network/aws"
  version = "0.6.12"

  availability_zones     = var.availability_zones
  name                   = var.cluster_name
  private_subnet_netmask = var.private_subnet_netmask
  ipam_pool_id           = local.ipam_pool_id
  tags                   = local.tags
  transit_gateway_id     = local.transit_gateway_id
  vpc_cidr               = var.vpc_cidr

  # By default we route all traffic to the transit gateway
  transit_gateway_routes = {
    private = "0.0.0.0/0"
  }

  private_subnet_tags = {
    "karpenter.sh/discovery"                    = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"           = "1"
  }

  ## Assuming public subnets are being provisioned, we tag them with the cluster name
  public_subnet_tags = var.public_subnet_netmask > 0 ? {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/elb"                    = "1"
  } : null
}

## Provision an EKS container platform to deploy workloads
module "eks" {
  source  = "appvia/eks/aws"
  version = "1.2.6"

  access_entries         = local.access_entries
  cluster_name           = var.cluster_name
  enable_private_access  = true
  enable_public_access   = var.enable_public_access
  kms_key_administrators = [local.root_account_arn]
  kubernetes_version     = var.kubernetes_version
  pod_identity           = local.pod_identity
  private_subnet_ids     = local.private_subnet_ids
  tags                   = local.tags
  vpc_id                 = local.vpc_id

  ## Hub-Spoke configuration - if the cluster is part of a hub-spoke architecture,
  ## update the following variables
  hub_account_id   = var.hub_account_id
  hub_account_role = var.hub_account_role

  ## ArgoCD configuration
  argocd = {
    enable = true
  }
  ## Cert-manager configuration
  cert_manager = {
    enable = true
  }
  ## External Secrets configuration
  external_secrets = {
    enable = true
  }
  ## External DNS configuration
  external_dns = {
    enable = true
  }

  depends_on = [
    module.tenant_repository,
  ]
}

## Provision and bootstrap the platform using an tenant repository
module "platform" {
  count   = var.enable_platform ? 1 : 0
  source  = "appvia/eks/aws//modules/platform"
  version = "1.2.6"

  ## Name of the cluster
  cluster_name = module.eks.cluster_name
  # Any rrepositories to be provisioned
  repositories = var.argocd_repositories
  ## The platform repository - this is needed purely for the bootstraping the application
  platform_repository = try(var.platform.repository, "https://github.com/appvia/kubernetes-platform")
  # The location of the platform repository - this is needed purely for the bootstraping the application
  platform_revision = try(var.platform.revision, "main")
  # The location of the tenant repository
  tenant_repository = local.tenant_repository_url
  # You pretty much always want to use the HEAD
  tenant_revision = try(var.tenant_repository.revision, "main")
  ## The tenant repository path
  tenant_path = local.tenant_repository_path

  depends_on = [
    module.tenant_repository
  ]
}
