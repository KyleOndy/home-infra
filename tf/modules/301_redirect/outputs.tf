output "website_domain" {
  value = aws_s3_bucket.redirect.website_domain
}

output "hosted_zone_id" {
  value = aws_s3_bucket.redirect.hosted_zone_id
}
