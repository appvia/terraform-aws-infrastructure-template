## Configure the GitHub provider - required if you want the tenant repository 
##to be created in a separate repository to infrastructure pipeline
provider "github" {

  dynamic "app_auth" {
    for_each = try(var.github_app_id, null) != null ? [1] : []
    content {
      id              = try(var.github_app_id, null)
      installation_id = try(var.github_app_installation_id, null)
      pem_file        = try(var.github_app_private_key, null)
    }
  }
}

## Configure the Helm provider - used to install ArgoCD
provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

## Provision the kubectl provider - used to apply the platform configuration
provider "kubectl" {
  apply_retry_count      = 3
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  host                   = module.eks.cluster_endpoint
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}
