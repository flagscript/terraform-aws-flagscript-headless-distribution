# S3 
output "distribution_bucket_arn" {
  description = "Regional map of ARN for the S3 bucket."
  value       = { for region in local.deployment_regions : region => aws_s3_bucket.website_distribution_bucket[region].arn }
}

output "distribution_bucket_name" {
  description = "Regional map of name for the S3 bucket."
  value       = { for region in local.deployment_regions : region => aws_s3_bucket.website_distribution_bucket[region].bucket }
}

# Cloudfront
output "distribution_arn" {
  description = "ARN for the distribution."
  value       = aws_cloudfront_distribution.cloudfront_distribution.arn
}

output "distribution_domain_name" {
  description = "Domain name for the distribution."
  value       = aws_cloudfront_distribution.cloudfront_distribution.domain_name
}

output "distribution_hosted_zone_id" {
  description = "Hosted zone ID for the distribution."
  value       = aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id
}

output "distribution_id" {
  description = "Identifier for the distribution."
  value       = aws_cloudfront_distribution.cloudfront_distribution.id
}

# ACM
output "acm_certificate_arn" {
  description = "ARN for the ACM certificate."
  value       = aws_acm_certificate.website_certificate.arn
}
