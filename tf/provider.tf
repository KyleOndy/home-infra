terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  allowed_account_ids = ["436428857397"]
  region              = "us-east-1"
  default_tags {
    tags = {
      owner      = "kyle@ondy.org"
      managed_by = "https://github.com/KyleOndy/home-infra"
    }
  }
}
