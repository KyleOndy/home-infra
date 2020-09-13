provider "aws" {
  version             = "~> 2.0" # the S3 setup script still requires 2.x
  region              = "us-east-1"
  allowed_account_ids = ["436428857397"]
}
