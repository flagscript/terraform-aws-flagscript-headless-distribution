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

# Sign in with Google
resource "aws_cognito_identity_provider" "google" {
  provider = aws.cognito
  count    = var.login_with_google == null ? 0 : 1
  region   = var.user_pool_region

  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "Google"
  provider_type = "Google"

  # Cognito fills in the URL fields itself. Listing them here keeps every plan from showing a change.
  provider_details = {
    attributes_url                = "https://people.googleapis.com/v1/people/me?personFields="
    attributes_url_add_attributes = true
    authorize_scopes              = "openid email profile"
    authorize_url                 = "https://accounts.google.com/o/oauth2/v2/auth"
    client_id                     = var.login_with_google.client_id
    client_secret                 = var.login_with_google.client_secret
    oidc_issuer                   = "https://accounts.google.com"
    token_request_method          = "POST"
    token_url                     = "https://www.googleapis.com/oauth2/v4/token"
  }

  attribute_mapping = {
    email          = "email"
    email_verified = "email_verified"
    family_name    = "family_name"
    given_name     = "given_name"
    name           = "name"
    username       = "sub"
  }
}
