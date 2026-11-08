# User pool
output "user_pool_arn" {
  description = "Cognito user pool ARN."
  value       = aws_cognito_user_pool.this.arn
}

output "user_pool_domain_url" {
  description = "Base URL of the managed login pages, e.g. https://auth.example.com."
  value       = "https://${aws_cognito_user_pool_domain.this.domain}"
}

output "user_pool_endpoint" {
  description = "Cognito user pool endpoint."
  value       = aws_cognito_user_pool.this.endpoint
}

output "user_pool_id" {
  description = "Cognito user pool ID."
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_issuer_url" {
  description = "OIDC issuer for validating tokens on the website/API."
  value       = "https://${aws_cognito_user_pool.this.endpoint}"
}

# User pool edge client
output "edge_client_id" {
  description = "Cognito user pool edge client ID."
  value       = aws_cognito_user_pool_client.edge.id
}

output "edge_client_secret" {
  description = "Cognito user pool edge client secret."
  sensitive   = true
  value       = aws_cognito_user_pool_client.edge.client_secret
}
