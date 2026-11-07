# AWS lookups
data "aws_partition" "distribution" {
  provider = aws.dist
}

data "aws_caller_identity" "distribution" {
  provider = aws.dist
}

# Cloudfront
data "aws_cloudfront_response_headers_policy" "security_headers" {
  provider = aws.dist
  name     = "Managed-SecurityHeadersPolicy"
}
