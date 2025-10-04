cluster_name = "eks-dev"

tags = {
  Environment = "Production"
  GitRepo     = "https://github.com/appvia/terraform-aws-infrastructure-template"
  Owner       = "Development"
  Product     = "MyProduct"
  Provisioner = "Terraform"
}

access_entries = {
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
}
