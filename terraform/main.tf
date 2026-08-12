terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.3.0"
    }
  }
  required_version = ">= 1.2"
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}