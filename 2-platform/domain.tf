resource "aws_acm_certificate" "ecs-domain-certificate" {
  domain_name = "*.${var.ecs_domain_name}"
  validation_method = "DNS"

  tags = {
    Name = var.ecs_cluster_name+"-Certificate"
  }
}

data "aws_route53_zone" "ecs_domain" {
  name = var.ecs_domain_name
  private_zone = false
}

resource "aws_route53_record" "ecs-cert-validation-record" {
  name    = aws_acm_certificate.ecs-domain-certificate.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.ecs-domain-certificate.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.ecs_domain.zone_id
  records = [aws_acm_certificate.ecs-domain-certificate.domain_validation_options.0.resource_record_value]
  ttl     = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "ecs-domain-certificate-validation" {
  certificate_arn = aws_acm_certificate.ecs-domain-certificate.arn
  validation_record_fqdns = [aws_route53_record.ecs-cert-validation-record.fqdn]
}