# cognito user pool
data "aws_cognito_user_pool" "this" {
  region       = var.user_pool_region
  user_pool_id = var.user_pool_id
}
