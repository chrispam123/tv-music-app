# Provider configuration
# Specifies which version of the AWS provider to use

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      Project     = "tv-music-app"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}
