# The name of the cluster to provision
cluster_name = "prod"
# Indicates if we should enable the platform
enable_platform = true
# The platform repository
platform = {
  # The platform repository
  repository = "https://github.com/appvia/kubernetes-platform"
  # The platform revision
  revision = "v0.2.14"
}

## Tags to apply to the EKS cluster
tags = {
  # Name of the environment we are deploying to
  Environment = "Production"
  # The Git repository we are deploying from
  GitRepo = "https://github.com/appvia/terraform-aws-infrastructure-template"
  # The owner of the environment
  Owner = "Development"
  # The product of the environment
  Product = "MyProduct"
  # The provisioner of the environment
  Provisioner = "Terraform"
}
