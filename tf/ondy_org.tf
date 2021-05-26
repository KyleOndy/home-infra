resource "aws_route53_zone" "ondy_org" {
  name = "ondy.org"
}

output "ondy_org_nameservers" {
  value = aws_route53_zone.ondy_org.name_servers
}

resource "aws_route53_record" "ondy_org_apps_star_cname" {
  zone_id = aws_route53_zone.ondy_org.zone_id
  name    = "*.apps.ondy.org"
  type    = "CNAME"
  ttl     = "300"
  records = ["home.509ely.com"]
}

resource "aws_route53_record" "org_ondy_mx" {
  zone_id = aws_route53_zone.ondy_org.zone_id
  name    = "ondy.org"
  type    = "MX"
  ttl     = "3600"
  records = [
    "10 london.mxroute.com",
    "20 london-relay.mxroute.com",
  ]
}

resource "aws_route53_record" "org_ondy_txt" {
  zone_id = aws_route53_zone.ondy_org.zone_id
  name    = "ondy.org"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=spf1 include:mxroute.com -all"]
}

resource "aws_route53_record" "org_ondy_apex" {
  zone_id = aws_route53_zone.ondy_org.zone_id
  name    = "ondy.org"
  type    = "A"

  alias {
    name                   = aws_s3_bucket.org_ondy_redirect.website_domain
    zone_id                = aws_s3_bucket.org_ondy_redirect.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_org_ondy" {
  zone_id = aws_route53_zone.ondy_org.zone_id
  name    = "www.ondy.org"
  type    = "CNAME"
  ttl     = "300"
  records = ["home.509ely.com"]
}

resource "aws_s3_bucket" "org_ondy_redirect" {
  bucket = "ondy.org"
  acl    = "private"

  website {
    redirect_all_requests_to = "https://www.ondy.org"
  }
}
