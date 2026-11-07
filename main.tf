
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
    var.tags,
    {
      Name = "${local.normalized_domain}-distribution"
    }
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
    target_origin_id           = "s3-failover"
    viewer_protocol_policy     = "redirect-to-https"
  }

  dynamic "origin" {
    for_each = aws_s3_bucket.website_distribution_bucket
    content {
      connection_attempts      = 3
      connection_timeout       = 10
      domain_name              = origin.value.bucket_regional_domain_name
      origin_access_control_id = aws_cloudfront_origin_access_control.origin_access_control.id
      origin_id                = origin.value.region == var.s3_origin_primary_region ? "primary" : "secondary"
    }
  }

  origin_group {
    origin_id = "s3-failover"
    failover_criteria {
      status_codes = [500, 502, 503, 504]
    }
    member { origin_id = "primary" }
    dynamic "member" {
      for_each = var.s3_origin_backup_region == null ? [] : ["secondary"]
      content {
        origin_id = "secondary"
      }
    }
  }

  # origin {
  #   connection_attempts      = 3
  #   connection_timeout       = 10
  #   domain_name              = aws_s3_bucket.website_distribution_bucket.bucket_regional_domain_name
  #   origin_access_control_id = aws_cloudfront_origin_access_control.origin_access_control.id
  #   origin_id                = local.s3_origin_id
  # }

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
