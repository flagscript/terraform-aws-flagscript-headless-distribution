output "distribution_arn" {
  description = "ARN of the CloudFront distribution."
  value       = module.headless_distribution.distribution_arn
}

output "distribution_id" {
  description = "ID of the CloudFront distribution."
  value       = module.headless_distribution.distribution_id
}
