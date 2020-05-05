data "aws_route53_zone" "kyleondy_com" {
  zone_id = local.kyleondy_com_zone_id
}

module "kyleondy_com_redirect" {
  source            = "./modules/301_redirect"
  redirect_location = "https://www.kyleondy.com" # todo: magic stirng
}

resource "aws_route53_record" "kyleondy_com_a" {
  name    = "kyleondy.com"
  zone_id = data.aws_route53_zone.kyleondy_com.zone_id
  type    = "A"

  alias {
    name                   = module.kyleondy_com_redirect.website_domain
    zone_id                = module.kyleondy_com_redirect.hosted_zone_id
    evaluate_target_health = true
  }
}

# "old" website on s3
data "aws_s3_bucket" "www_kyleondy_com" {
  bucket = "www.kyleondy.com"
}

# drop ttl before making big changes.
resource "aws_route53_record" "www_kyleondy_com_cname" {
  zone_id = data.aws_route53_zone.kyleondy_com.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = "300"                             # todo: seconds?
  records = ["kyleondy-prod.apps.509ely.com"] # todo: magic string
  #records = [data.aws_s3_bucket.www_kyleondy_com.website_endpoint]
}

resource "aws_route53_record" "www-latest_kyleondy_com_cname" {
  zone_id = data.aws_route53_zone.kyleondy_com.zone_id
  name    = "www-lastest"
  type    = "CNAME"
  ttl     = "3600"
  records = ["kyleondy-latest.apps.509ely.com"] # todo: magic string
}

resource "aws_route53_record" "kyleondy_com_mx" {
  zone_id = data.aws_route53_zone.kyleondy_com.zone_id
  name    = "kyleondy.com"
  type    = "MX"
  ttl     = "3600"
  records = [
    "10 london.mxroute.com",
    "20 london-relay.mxroute.com",
  ]

}

resource "aws_route53_record" "kyleondy_com_txt" {
  zone_id = data.aws_route53_zone.kyleondy_com.zone_id
  name    = "kyleondy.com"
  type    = "TXT"
  ttl     = "3600"
  records = [
    "v=spf1 include:mxroute.com -all",
  ]
}
