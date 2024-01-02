data "aws_route53_zone" "route53_zone" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "stage" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.domain1
  type    = "A"
  alias{
    name =var.stage_lb_dns_name
    zone_id = var.stage_lb_zoneid
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "prod" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.domain2
  type    = "A"
  alias{
    name =var.prod_lb_dns_name
    zone_id = var.prod_lb_zoneid
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "graf" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.domain3
  type    = "A"
  alias{
    name =var.graf_lb_dns_name
    zone_id = var.graf_lb_zoneid
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "prom" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.domain4
  type    = "A"
  alias{
    name =var.prom_lb_dns_name
    zone_id = var.prom_lb_zoneid
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "cert-ssl" {
  domain_name       = var.domain
  validation_method = "DNS"
  subject_alternative_names = [var.domain5]
}

resource "aws_route53_record" "record" {
    for_each = {
        for dvo in aws_acm_certificate.cert-ssl.domain_validation_options : dvo.domain_name => {
            name   = dvo.resource_record_name
            record = dvo.resource_record_value
            type   = dvo.resource_record_type
        }
    }
    allow_overwrite = true
    name    = each.value.name
    records = [each.value.record]
    ttl     = 60
    type    = each.value.type
    zone_id = data.aws_route53_zone.route53_zone.zone_id
 
}

resource "aws_acm_certificate_validation" "ssl-validation" {
    certificate_arn = aws_acm_certificate.cert-ssl.arn
    validation_record_fqdns = [for record in aws_route53_record.record : record.fqdn]
}
  