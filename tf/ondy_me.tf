resource "aws_route53_zone" "ondy_me" {
  name = "ondy.me"
}

output "ondy_me_nameservers" {
  value = aws_route53_zone.ondy_me.name_servers
}

resource "aws_route53_record" "ondy_me_mx" {
  zone_id = aws_route53_zone.ondy_me.zone_id
  name    = "ondy.me"
  type    = "MX"
  ttl     = "3600"
  records = [
    "10 london.mxroute.com",
    "20 london-relay.mxroute.com",
  ]
}

resource "aws_route53_record" "ondy_me" {
  zone_id = aws_route53_zone.ondy_me.zone_id
  name    = "ondy.me"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=spf1 include:mxroute.com -all"]
}

resource "aws_route53_record" "ondy_me_apex" {
  zone_id = aws_route53_zone.ondy_me.zone_id
  name    = "ondy.me"
  type    = "A"

  alias {
    name                   = aws_s3_bucket.ondy_me_redirect.website_domain
    zone_id                = aws_s3_bucket.ondy_me_redirect.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_ondy_me" {
  zone_id = aws_route53_zone.ondy_me.zone_id
  name    = "www.ondy.me"
  type    = "CNAME"
  ttl     = "300"
  records = ["home.509ely.com"]
}

resource "aws_s3_bucket" "ondy_me_redirect" {
  bucket = "ondy.me"
  acl    = "private"

  website {
    redirect_all_requests_to = "https://www.kyleondy.com"
  }
}
