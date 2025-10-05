
locals {
  ## Additional pod identity configuration
  ## Documentation: https://registry.terraform.io/providers/terraform-aws-modules/eks/latest/docs/modules/pod_identity
  pod_identity = merge(var.pod_identity, {
    eks_admin = {
      enabled         = true
      namespace       = "eks-admin"
      service_account = "eks-admin"
    }
  })
}
