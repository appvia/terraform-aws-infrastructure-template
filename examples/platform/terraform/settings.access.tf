
locals {
  ## Additional access entries to add to the cluster
  ## Documentation: https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_access_settings
  access_entries = merge(var.access_entries, {
    eks_admin = {
      principal_arn = "arn:aws:iam::${local.account_id}:user/eks-admin"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  })
}
