data "aws_route53_zone" "ondy_org" {
  zone_id = local.ondy_org_zone_id
}

resource "aws_route53_record" "git_ondy_org_cname" {
  zone_id = data.aws_route53_zone.ondy_org.zone_id
  name    = "git"
  type    = "CNAME"
  ttl     = "300"
  records = ["git.apps.509ely.com"] # todo: magic string
}

resource "aws_route53_record" "ondy_org_mx" {
  zone_id = data.aws_route53_zone.ondy_org.zone_id
  name    = "ondy.org"
  type    = "MX"
  ttl     = "3600"
  records = [
    "10 london.mxroute.com",
    "20 london-relay.mxroute.com",
  ]
}

resource "aws_route53_record" "ondy_org_txt" {
  zone_id = data.aws_route53_zone.ondy_org.zone_id
  name    = "ondy.org"
  type    = "TXT"
  ttl     = "3600"
  records = [
    "v=spf1 include:mxroute.com -all",
  ]
}
