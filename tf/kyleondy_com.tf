resource "aws_route53_zone" "kyleondy_com" {
  name = "kyleondy.com"
}

output "kyleondy_com_nameservers" {
  value = aws_route53_zone.kyleondy_com.name_servers
}

resource "aws_route53_record" "kyleondy_com_apex" {
  zone_id = aws_route53_zone.kyleondy_com.zone_id
  name    = "kyleondy.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.ec2_redirect.public_ip]
}

resource "aws_route53_record" "www_kyleondy_com" {
  zone_id = aws_route53_zone.kyleondy_com.zone_id
  name    = "www.kyleondy.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["kyleondy-web.apps.509ely.com"]
}

#resource "aws_s3_bucket" "kyleondy_com_redirect" {
#  bucket = "kyleondy.com"
#  acl    = "private"
#
#  website {
#    redirect_all_requests_to = "https://www.kyleondy.com"
#  }
#}
