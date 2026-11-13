# lambda cloudwatch log group
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  for_each          = toset(local.deployment_regions)
  region            = each.key
  name              = "/aws/lambda/${var.user_pool_name}-pre-auth"
  retention_in_days = var.log_retention_days
  tags = merge(
    {
      "Name" = "/aws/lambda/${var.user_pool_name}-pre-auth"
    },
    local.common_tags
  )
}
