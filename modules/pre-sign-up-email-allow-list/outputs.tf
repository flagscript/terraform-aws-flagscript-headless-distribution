output "lambda_function_arn" {
  description = "Regional map of ARNs of the pre sign-up Lambda. Set it as lambda_config.pre_sign_up on your user pool."
  value       = { for region, function in aws_lambda_function.pre_sign_up_lambda : region => function.arn }
}

output "lambda_function_name" {
  description = "Name of the pre sign-up Lambda."
  value       = aws_lambda_function.pre_sign_up_lambda[var.user_pool_region].function_name
}

output "table_name" {
  description = "Name of the DynamoDB allow-list table."
  value       = aws_dynamodb_table.allow_list_dynamo_table.name
}

output "table_arn" {
  description = "Regional map of ARNs of the DynamoDB allow-list table: the primary region plus any replica regions."
  value = merge(
    { (var.user_pool_region) = aws_dynamodb_table.allow_list_dynamo_table.arn },
    { for replica in aws_dynamodb_table.allow_list_dynamo_table.replica : replica.region_name => replica.arn },
  )
}
