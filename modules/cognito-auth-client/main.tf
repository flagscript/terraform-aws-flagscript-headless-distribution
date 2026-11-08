# User Pool Client
resource "aws_cognito_user_pool_client" "this" {
  region                               = var.user_pool_region
  access_token_validity                = var.access_token_validity_minutes
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  callback_urls                        = var.callback_urls
  enable_token_revocation              = true
  explicit_auth_flows = concat(
    # Public clients also allow SRP sign-in from browser code; confidential clients
    # only sign in through the managed login pages.
    ["ALLOW_REFRESH_TOKEN_AUTH"],
    local.public_auth_client ? ["ALLOW_USER_SRP_AUTH"] : []
  )
  generate_secret               = !local.public_auth_client
  id_token_validity             = var.access_token_validity_minutes
  logout_urls                   = var.logout_urls
  name                          = var.client_name
  prevent_user_existence_errors = "ENABLED"
  read_attributes               = ["email", "email_verified", "given_name", "family_name", "name"]
  refresh_token_validity        = var.refresh_token_validity_days
  # COGNITO is always enabled. Pass module.<pool>.identity_provider_names rather than
  # literal names, so Terraform creates each provider before the client that lists it.
  supported_identity_providers = concat(["COGNITO"], var.identity_provider_names)
  user_pool_id                 = var.user_pool_id
  write_attributes             = ["email", "given_name", "family_name", "name"]

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

# Managed login pages with Cognito's default look. Customise colours, logo and
# background later in the console's branding editor, or by switching to
# `settings` and `asset` blocks here.
resource "aws_cognito_managed_login_branding" "managed_login_pages" {
  region                      = var.user_pool_region
  user_pool_id                = var.user_pool_id
  client_id                   = aws_cognito_user_pool_client.this.id
  use_cognito_provided_values = true
}
