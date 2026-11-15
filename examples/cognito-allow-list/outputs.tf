output "user_pool_arn" {
  description = "ARN of the Cognito user pool."
  value       = module.user_pool.user_pool_arn
}

output "user_pool_domain_url" {
  description = "Base URL of the managed login pages."
  value       = module.user_pool.user_pool_domain_url
}

output "pre_sign_up_lambda_arn" {
  description = "Regional map of ARNs of the pre sign-up Lambda."
  value       = module.email_allow_list.lambda_function_arn
}

output "allow_list_table_name" {
  description = "Name of the DynamoDB allow-list table. Add allowed emails here."
  value       = module.email_allow_list.table_name
}

output "allow_list_table_arn" {
  description = "Regional map of ARNs of the DynamoDB allow-list table."
  value       = module.email_allow_list.table_arn
}
