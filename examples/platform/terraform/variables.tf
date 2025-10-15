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

variable "availability_zones" {
  description = "The availability zones to provision the cluster in"
  type        = number
  default     = 3
}

variable "cluster_name" {
  description = "The name of the cluster to provision"
  type        = string
}

variable "enable_platform" {
  description = "Indicates we should install the platform"
  type        = bool
  default     = true
}

variable "enable_public_access" {
  description = "Indicates we should enable public access to the cluster"
  type        = bool
  default     = false
}

variable "github_app_id" {
  description = "The ID of the GitHub App"
  type        = string
  default     = null
}

variable "github_app_installation_id" {
  description = "The installation ID of the GitHub App"
  type        = string
  default     = null
}

variable "github_app_private_key" {
  description = "The private key of the GitHub App"
  type        = string
  default     = null
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

variable "ipam_pool_name" {
  description = "The name of the IPAM pool to use for the network, if using IPAM"
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "The version of the cluster to provision"
  type        = string
  default     = "1.34"
}

variable "platform" {
  description = "The platform configuration"
  type = object({
    repository = string
    revision   = string
  })
  default = {
    repository = "https://github.com/appvia/kubernetes-platform"
    revision   = "v0.1.3"
  }
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

variable "private_subnet_netmask" {
  description = "The netmask for the private subnets"
  type        = number
  default     = 24
}

variable "public_subnet_netmask" {
  description = "The netmask for the public subnets"
  type        = number
  default     = 0
}

variable "tags" {
  description = "The tags to apply to all resources"
  type        = map(string)
}

variable "tenant_repository" {
  description = "Configuration for the tenant repository, containing application definitions"
  type = object({
    # The name of the repository (the full url of the repository)
    repository = string
    # The description of the repository
    description = string
    # The visibility of the repository (private, public, etc.)
    visibility = optional(string, "private")
    # Whether to create the repository
    create = optional(bool, false)
  })
  default = null
}

variable "transit_gateway_id" {
  description = "The transit gateway ID to associate with the network"
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = null
}

variable "vpc_name" {
  description = "When reusing an existing VPC, this is the name of the VPC"
  type        = string
  default     = null
}
