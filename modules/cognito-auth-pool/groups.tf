# Cognito user groups
resource "aws_cognito_user_group" "this" {
  provider = aws.cognito
  for_each = var.groups
  region   = var.user_pool_region

  description  = each.value
  name         = each.key
  user_pool_id = aws_cognito_user_pool.this.id
}
