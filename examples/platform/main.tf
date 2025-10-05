
#
## Provision a Container Platform
#
# Uncomment the following resources to provision a container platform (EKS) if you 
# are using the Platform pattern: https://github.com/appvia/kubernetes-platform
#

## Provision a repository used to store the application workloads definitions
module "tenant_repository" {
  count   = var.tenant_repository.create ? 1 : 0
  source  = "appvia/repository/github"
  version = "1.1.3"

  repository  = basename(var.tenant_repository.repository)
  description = local.tenant_repository_description
  visibility  = var.tenant_repository.visibility

  # Template settings
  template = var.tenant_repository.template != null ? {
    owner      = var.tenant_repository.template.owner
    repository = var.tenant_repository.template.repository
  } : null

  # Branch rules 
  allow_auto_merge       = true
  allow_merge_commit     = true
  allow_rebase_merge     = true
  allow_squash_merge     = true
  delete_branch_on_merge = true

  branch_protection = {
    main = {
      allows_force_pushes             = false
      allows_deletions                = false
      require_conversation_resolution = true
      require_signed_commits          = true
      required_linear_history         = false

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

## Provision an EKS container platform to deploy workloads
module "eks" {
  source  = "appvia/eks/aws"
  version = "1.0.0"

  access_entries         = local.access_entries
  cluster_name           = var.cluster_name
  endpoint_public_access = var.endpoint_public_access
  kms_key_administrators = [local.root_user_arn]
  kubernetes_version     = var.kubernetes_version
  pod_identity           = local.pod_identity
  private_subnet_ids     = data.aws_subnets.private_subnets.ids
  tags                   = local.tags
  vpc_id                 = local.vpc_id

  ## Hub-Spoke configuration - if the cluster is part of a hub-spoke architecture, update the 
  ## following variables
  hub_account_id   = var.hub_account_id
  hub_account_role = var.hub_account_role

  ## Certificate manager configuration
  cert_manager = {
    enabled         = true
    namespace       = "cert-manager"
    service_account = "cert-manager"
    # Route53 zone ARNs to attach to the Certificate Manager platform
    route53_zone_arns = []
  }

  ## ArgoCD configuration
  argocd = {
    enabled         = true
    namespace       = "argocd"
    service_account = "argocd"
  }

  external_secrets = {
    enabled              = true
    namespace            = "external-secrets"
    service_account      = "external-secrets"
    secrets_manager_arns = ["arn:aws:secretsmanager:*:*"]
    ssm_parameter_arns   = ["arn:aws:ssm:*:*:parameter/eks/*"]
  }

  ## External DNS configuration
  external_dns = {
    enabled         = true
    namespace       = "external-dns"
    service_account = "external-dns"
    # Route53 zone ARNs to attach to the External DNS platform
    route53_zone_arns = []
  }

  depends_on = [module.workloads_repository]
}

## Provision and bootstrap the platform using an tenant repository
module "platform" {
  count  = var.enable_platform ? 1 : 0
  source = "github.com/gambol99/terraform-kube-platform?ref=v0.1.3"

  ## Name of the cluster
  cluster_name = var.cluster_name
  # The type of cluster
  cluster_type = var.cluster_type
  # Any rrepositories to be provisioned
  repositories = var.argocd_repositories
  ## Revision overrides
  revision_overrides = var.revision_overrides
  ## The platform repository
  platform_repository = var.platform.repository
  # The location of the platform repository
  platform_revision = var.platform.revision
  # The location of the tenant repository
  tenant_repository = var.tenant_repository.repository
  # You pretty much always want to use the HEAD
  tenant_revision = "main"
  ## The tenant repository path
  tenant_path = "."

  depends_on = [
    module.eks
  ]
}
