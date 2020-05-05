locals {
  clean_location = replace(replace(var.redirect_location, "https://", ""), "http://", "")
}


resource "aws_s3_bucket" "redirect" {
  bucket_prefix = local.clean_location
  #acl           = "public-read"
  #policy = "${file("policy.json")}"

  website {
    redirect_all_requests_to = var.redirect_location
  }
}
