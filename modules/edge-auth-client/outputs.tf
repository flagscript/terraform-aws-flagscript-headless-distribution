# Client
output "edge_client_id" {
  description = "Cognito user pool client ID."
  value       = aws_cognito_user_pool_client.edge.id
}

output "edge_client_secret" {
  description = "Cognito user pool client secret."
  sensitive   = true
  value       = aws_cognito_user_pool_client.edge.client_secret
}
