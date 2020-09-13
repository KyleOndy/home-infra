# TODO:
#       - move aidenondy.com
#       - move kyleondy.com
#       - move ondy.me
#       - move ondy.xyz

resource "aws_route53_zone" "ondy_org" {
  name = "ondy.org"
}

resource "aws_route53_record" "ondy_org_apps_star_cname" {
  zone_id = aws_route53_zone.ondy_org.zone_id
  name    = "*.apps.ondy.org"
  type    = "CNAME"
  ttl     = "300"
  records = ["home.509ely.com"]
}

# todo: remove this
resource "aws_route53_record" "ondy_org_infra_web_cname" {
  zone_id = aws_route53_zone.ondy_org.zone_id
  name    = "web.infra.ondy.org"
  type    = "CNAME"
  ttl     = "300"
  records = ["home.509ely.com"]
}

output "ondy_org_nameservers" {
  value = aws_route53_zone.ondy_org.name_servers
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

resource "aws_route53_record" "org_ondy_lists_a" {
  zone_id = aws_route53_zone.ondy_org.zone_id
  name    = "lists.ondy.org"
  type    = "A"
  ttl     = "300"
  records = ["192.34.61.247"]
}

resource "aws_route53_record" "org_ondy_lists_aaaa" {
  zone_id = aws_route53_zone.ondy_org.zone_id
  name    = "lists.ondy.org"
  type    = "AAAA"
  ttl     = "300"
  records = ["2604:a880:400:d0::c0e:2001"]
}

resource "aws_route53_record" "org_ondy_lists_mx" {
  zone_id = aws_route53_zone.ondy_org.zone_id
  name    = "lists.ondy.org"
  type    = "MX"
  ttl     = "300"
  records = ["10 mailmanlists.network"]
}

resource "aws_route53_record" "org_ondy_lists_txt" {
  zone_id = aws_route53_zone.ondy_org.zone_id
  name    = "lists.ondy.org"
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 mx a ip4:192.34.61.247 ip6:2604:a880:400:d0::c0e:2001 ~all"]
}

resource "aws_route53_record" "org_ondy_lists_dmarc_txt" {
  zone_id = aws_route53_zone.ondy_org.zone_id
  name    = "_dmarc.lists.ondy.org"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1; p=none; pct=100; rua=mailto:dmarc@mailmanlists.net; sp=none; aspf=r"]
}

resource "aws_route53_record" "org_ondy_lists_domainkey_mail_txt" {
  zone_id = aws_route53_zone.ondy_org.zone_id
  name    = "mail._domainkey.lists.ondy.org"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DKIM1; h=sha256; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDFLjQYTQZDqvJl3Cojb8MKQyHlVVfS7KOUDi6GlNBwomb02Ge5aKA2XRSGe2qx+vZpR/9GJN3t2RjR4Z3sboCdJdf3/2A6dpINmV3Qrts8fKlvRbRvJRHkErtvqH10NZwBtNqI/xpizcHCxJU77WzQ0yNaxxPJX8A7qOOiNUfo8QIDAQAB"]
}
