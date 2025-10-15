# The name of the cluster to provision
cluster_name = "dev"
# Indicates if we should enable the platform
enable_platform = true
# Indicates if we should enable the public access to the cluster (not recommended for production)
enable_public_access = true
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
