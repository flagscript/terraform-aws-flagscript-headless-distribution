# Acm
## Distribution Certificate
resource "aws_acm_certificate" "distribution_certificate" {
  domain_name       = var.domain
  key_algorithm     = "EC_prime256v1"
  validation_method = "DNS"
  tags = merge(
    local.common_tags,
    {
      Name = var.domain
    }
  )

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
}


# Cloudfront
## Origin Access Control
resource "aws_cloudfront_origin_access_control" "origin_access_control" {
  name                              = var.domain
  description                       = "Origin access control for ${var.domain}."
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

## Default cache behavior
resource "aws_cloudfront_cache_policy" "default_cache_policy" {
  name    = "${local.normalized_origin}-default-cache-policy"
  comment = "${local.normalized_origin} default cache policy"

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

## Distribution
locals {
  origin_id = "${local.normalized_origin}-s3-origin"
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  aliases             = [var.domain]
  comment             = "Distribution for ${var.domain}."
  default_root_object = var.default_root_object
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2"
  price_class         = "PriceClass_100"
  tags = merge(
    local.common_tags,
    {
      Name = "${local.normalized_origin}-distribution"
    }
  )

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = aws_cloudfront_cache_policy.default_cache_policy.id
    compress               = true
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
  }

  origin {
    domain_name              = module.distribution_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.origin_access_control.id
    origin_id                = local.origin_id
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.distribution_certificate.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

}


# S3
## Distribution origin
module "distribution_bucket" {
  source             = "flagscript/flagscript-s3-bucket/aws"
  version            = "3.0.0"
  bucket_name_prefix = "cloudfront"
  bucket_name_suffix = local.normalized_origin
  cloudfront_distribution_arns = [
    aws_cloudfront_distribution.cloudfront_distribution.arn
  ]
}
