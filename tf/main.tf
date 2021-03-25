terraform {
  #backend "remote" {
  #  organization = "ondy"

  #  workspaces {
  #    name = "home-infra"
  #  }
  #}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


# Configure the AWS Provider
provider "aws" {
  region              = "us-east-1"
  access_key          = "AKIAWLHJP4A2VKY63L4X" # svc.home-infra
  allowed_account_ids = ["436428857397"]
}
