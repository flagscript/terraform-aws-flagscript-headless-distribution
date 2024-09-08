output "distribution_arn" {
  description = "ARN for the distribution."
  value       = aws_cloudfront_distribution.cloudfront_distribution.arn
}

output "distribution_id" {
  description = "Identifier for the distribution."
  value       = aws_cloudfront_distribution.cloudfront_distribution.id
}
