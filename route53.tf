# Certificate Validation Records
resource "aws_route53_record" "website_certificate_validation_records" {
  provider = aws.dns
  for_each = {
    for dvo in aws_acm_certificate.website_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_id
}

# Create Route 53 A record (IPv4 Alias)
resource "aws_route53_record" "cloudfront_a_record" {
  provider = aws.dns
  zone_id  = var.hosted_zone_id
  name     = var.domain
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# Create Route 53 AAAA record (IPv6 Alias - Optional but recommended)
resource "aws_route53_record" "cloudfront_aaaa_record" {
  provider = aws.dns
  zone_id  = var.hosted_zone_id
  name     = var.domain
  type     = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
