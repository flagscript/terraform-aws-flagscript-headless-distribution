
# Primary region wildcard acm certificate
## certificate
resource "aws_acm_certificate" "website_certificate" {
  provider          = aws.dist
  region            = "us-east-1"
  domain_name       = var.domain
  key_algorithm     = var.acm_key_algorithm
  validation_method = "DNS"
  tags = merge(
    {
      Name = var.domain
    }
  )

  options {
    certificate_transparency_logging_preference = "ENABLED"
    export                                      = "DISABLED"
  }

  lifecycle {
    create_before_destroy = true
  }

}
