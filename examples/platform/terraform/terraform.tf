terraform {
  required_version = ">= 1.0.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.0.0"
    }
  }
}
