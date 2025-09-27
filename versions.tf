# -----------------------------
# Providers (top-level)
# -----------------------------
# Default AWS provider (your EKS region)

# Aliased AWS provider for Amazon Managed Grafana (supported region)
provider "aws" {
  alias  = "amg"
  region = "ap-southeast-1"
}

# -----------------------------
# Versions / required providers
# -----------------------------
terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.13"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }
  }
}

