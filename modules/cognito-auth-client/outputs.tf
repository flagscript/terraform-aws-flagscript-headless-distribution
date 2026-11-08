# Client
output "client_id" {
  description = "Cognito user pool client ID."
  value       = aws_cognito_user_pool_client.this.id
}

output "client_secret" {
  description = "Cognito user pool client secret. null for public clients."
  sensitive   = true
  value       = aws_cognito_user_pool_client.this.client_secret
}
