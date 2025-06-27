terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Specify the required version of the AWS provider
    }
  }

  required_version = ">= 1.5.0" # Specify the required Terraform version
}