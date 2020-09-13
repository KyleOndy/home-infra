terraform {
  required_version = ">= 0.12.2"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "ondy-prod-terraform-state"
    key            = "terraform.tfstate"
    dynamodb_table = "ondy-prod-terraform-state-lock"
    profile        = ""
    role_arn       = ""
    encrypt        = "true"
  }
}
