resource "aws_cloudfront_cache_policy" "default_cache_policy" {
  provider    = aws.dist
  comment     = "${var.domain} default cache policy"
  default_ttl = 86400
  max_ttl     = 86400
  min_ttl     = 0
  name        = "${local.normalized_domain}-default-cache-policy"

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


resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  provider            = aws.dist
  aliases             = [var.domain]
  comment             = "Distribution for ${var.domain}."
  default_root_object = var.default_root_object
  enabled             = true
  is_ipv6_enabled     = true
  http_version        = var.http_version
  price_class         = var.price_class
  # web_acl_id          = var.web_acl_arn
  tags = merge(
    local.common_tags,
    {
      Name = "${local.normalized_domain}-distribution"
    },
  )

  dynamic "custom_error_response" {
    for_each = var.custom_404_page == "" ? [] : ["custom_404_page"]
    content {
      error_code         = 404
      response_code      = 200
      response_page_path = var.custom_404_page
    }
  }

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    cache_policy_id            = aws_cloudfront_cache_policy.default_cache_policy.id
    compress                   = true
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id
    target_origin_id           = local.use_s3_failover ? "s3-failover" : "primary"
    viewer_protocol_policy     = "redirect-to-https"
  }

  dynamic "origin" {
    for_each = aws_s3_bucket.website_distribution_bucket
    content {
      connection_attempts      = var.origin_connection_attempts
      connection_timeout       = var.origin_connection_timeout
      domain_name              = origin.value.bucket_regional_domain_name
      origin_access_control_id = aws_cloudfront_origin_access_control.origin_access_control.id
      origin_id                = origin.key == var.s3_origin_primary_region ? "primary" : "secondary"
    }
  }

  # Origin groups require exactly two members, so only create one when failing over.
  dynamic "origin_group" {
    for_each = local.use_s3_failover ? ["s3-failover"] : []
    content {
      origin_id = origin_group.value
      failover_criteria {
        status_codes = var.failover_status_codes
      }
      member { origin_id = "primary" }
      member { origin_id = "secondary" }
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.website_certificate.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

}
