# Login with Amazon
resource "aws_cognito_identity_provider" "amazon" {
  provider = aws.cognito
  count    = var.login_with_amazon == null ? 0 : 1
  region   = var.user_pool_region

  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "LoginWithAmazon"
  provider_type = "LoginWithAmazon"

  provider_details = {
    attributes_url                = "https://api.amazon.com/user/profile"
    attributes_url_add_attributes = false
    authorize_scopes              = "profile"
    authorize_url                 = "https://www.amazon.com/ap/oa"
    client_id                     = var.login_with_amazon.client_id
    client_secret                 = var.login_with_amazon.client_secret
    token_request_method          = "POST"
    token_url                     = "https://api.amazon.com/auth/o2/token"
  }

  attribute_mapping = {
    email    = "email"
    name     = "name"
    username = "user_id"
  }
}
