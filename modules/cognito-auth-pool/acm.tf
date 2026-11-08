# Custom domain acm certificate
## certificate
resource "aws_acm_certificate" "custom_domain_certificate" {
  provider          = aws.cognito
  region            = "us-east-1"
  domain_name       = var.user_pool_custom_domain
  key_algorithm     = var.acm_key_algorithm
  validation_method = "DNS"
  tags = merge(
    local.common_tags,
    {
      "Name" = var.user_pool_custom_domain
    },
  )

  options {
    certificate_transparency_logging_preference = "ENABLED"
    export                                      = "DISABLED"
  }

  lifecycle {
    create_before_destroy = true
  }

}

## Wait for DNS validation to complete
resource "aws_acm_certificate_validation" "custom_domain_certificate_validation" {
  provider        = aws.cognito
  region          = "us-east-1"
  certificate_arn = aws_acm_certificate.custom_domain_certificate.arn
  validation_record_fqdns = [
    for _, record in aws_route53_record.custom_domain_certificate_validation_records : record.fqdn
  ]
}
