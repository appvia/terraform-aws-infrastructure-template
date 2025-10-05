variable "tags" {
  description = "The tags to apply to all resources"
  type        = map(string)
}

variable "workloads_repository_name" {
  description = "The name of the repository used to store the workload definitions"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster to provision"
  type        = string
}

variable "kubernetes_version" {
  description = "The version of the cluster to provision"
  type        = string
  default     = "1.32"
}

variable "github_template" {
  description = "The owner of the GitHub template"
  type = object({
    owner      = string
    repository = string
  })
  default = {
    owner      = "appvia"
    repository = "container-platform-template"
  }
}

variable "github_app_id" {
  description = "The ID of the GitHub App"
  type        = string
}

variable "github_app_installation_id" {
  description = "The installation ID of the GitHub App"
  type        = string
}

variable "github_app_private_key" {
  description = "The private key of the GitHub App"
  type        = string
}

variable "access_entries" {
  description = "Map of access entries to add to the cluster. This is required if you use a different IAM Role for Terraform Plan actions."
  type = map(object({
    ## The list of kubernetes groups to associate the principal with
    kubernetes_groups = optional(list(string))
    ## The list of kubernetes users to associate the principal with
    principal_arn = string
    ## The list of kubernetes users to associate the principal with
    policy_associations = optional(map(object({
      ## The policy arn to associate with the principal
      policy_arn = string
      ## The access scope for the policy i.e. cluster or namespace
      access_scope = object({
        ## The namespaces to apply the policy to
        namespaces = optional(list(string))
        ## The type of access scope i.e. cluster or namespace
        type = string
      })
    })))
  }))
  default = null
}

variable "pod_identity" {
  description = "The pod identity configuration"
  type = map(object({
    ## Indicates if we should enable the pod identity
    enabled = optional(bool, true)
    ## The namespace to deploy the pod identity to
    description = optional(string, null)
    ## The service account to deploy the pod identity to
    service_account = optional(string, null)
    ## The managed policy ARNs to attach to the pod identity
    managed_policy_arns = optional(map(string), {})
    ## The permissions boundary ARN to use for the pod identity
    permissions_boundary_arn = optional(string, null)
    ## The namespace to deploy the pod identity to
    namespace = optional(string, null)
    ## The name of the pod identity role
    name = optional(string, null)
    ## Additional policy statements to attach to the pod identity role
    policy_statements = optional(list(object({
      sid       = optional(string, null)
      actions   = optional(list(string), [])
      resources = optional(list(string), [])
      effect    = optional(string, null)
    })), [])
  }))
  default = {}
}

variable "argocd_repositories" {
  description = "A collection of repository secrets to add to the argocd namespace"
  type = map(object({
    ## The description of the repository
    description = string
    ## An optional password for the repository
    password = optional(string, null)
    ## The secret to use for the repository
    secret = optional(string, null)
    ## The secret manager ARN to use for the secret
    secret_manager_arn = optional(string, null)
    ## An optional SSH private key for the repository
    ssh_private_key = optional(string, null)
    ## The URL for the repository
    url = string
    ## An optional username for the repository
    username = optional(string, null)
  }))
  default = {}
}

variable "endpoint_public_access" {
  description = "The public access to the cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_path" {
  description = "The name of the cluster"
  type        = string
}


variable "enable_platform" {
  description = "Indicates we should install the platform"
  type        = bool
  default     = true
}

variable "hub_account_id" {
  description = "When using a hub deployment options, this is the account where argocd is running"
  type        = string
  default     = null
}

variable "hub_account_role" {
  description = "The role to use for the hub account"
  type        = string
  default     = "argocd-pod-identity-hub"
}

variable "vpc_name" {
  description = "The ID of the VPC to deploy the cluster into"
  type        = string
  default     = "lz-main"
}

variable "revision_overrides" {
  description = "The revision overrides to use for the platform and tenant repositories"
  type        = map(string)
  default     = {}
}
