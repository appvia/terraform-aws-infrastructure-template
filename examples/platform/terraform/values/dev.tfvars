# The name of the repository used to store the workload definitions 
#workloads_repository_name = UPDATE ME
# The name of the cluster to provision
cluster_name = "eks-dev"
## Override revision or branch for the platform and tenant repositories
revision_overrides = {}
# Indicates if we should enable the platform
enable_platform = true
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
