# Login with Amazon
resource "aws_cognito_identity_provider" "amazon" {
  provider = aws.cognito
  count    = var.login_with_amazon == null ? 0 : 1
  region   = var.user_pool_region

  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "LoginWithAmazon"
  provider_type = "LoginWithAmazon"

  provider_details = {
    client_id        = var.login_with_amazon.client_id
    client_secret    = var.login_with_amazon.client_secret
    authorize_scopes = "profile"
  }

  attribute_mapping = {
    email    = "email"
    name     = "name"
    username = "user_id"
  }
}
