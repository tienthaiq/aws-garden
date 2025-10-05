terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14"
    }
  }

  backend "s3" {
    bucket = "tientq-terraform"
    key    = "aws-garden/terraform.tfstate"
    region = "ap-southeast-1"
  }

  required_version = ">= 1.13"
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      service = "terraform"
    }
  }
}
