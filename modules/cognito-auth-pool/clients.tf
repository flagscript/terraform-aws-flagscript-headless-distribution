# User Pool Client

resource "aws_cognito_user_pool_client" "public_client" {
  provider                             = aws.cognito
  region                               = var.user_pool_region
  access_token_validity                = var.access_token_validity_minutes
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  callback_urls                        = var.callback_urls
  enable_token_revocation              = true
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]
  generate_secret               = false
  id_token_validity             = var.access_token_validity_minutes
  logout_urls                   = var.logout_urls
  name                          = "${var.user_pool_name}-public-client"
  prevent_user_existence_errors = "ENABLED"
  read_attributes               = ["email", "email_verified", "given_name", "family_name", "name"]
  refresh_token_validity        = var.refresh_token_validity_days
  # Referencing the provider resources (not literal names) makes Terraform
  # create each identity provider before the client that lists it.
  supported_identity_providers = concat(
    ["COGNITO"],
    # aws_cognito_identity_provider.google[*].provider_name,
    # aws_cognito_identity_provider.facebook[*].provider_name,
    # aws_cognito_identity_provider.amazon[*].provider_name,
    # aws_cognito_identity_provider.apple[*].provider_name,
  )
  user_pool_id     = aws_cognito_user_pool.this.id
  write_attributes = ["email", "given_name", "family_name", "name"]

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
  provider                    = aws.cognito
  depends_on                  = [aws_cognito_user_pool_domain.this]
  region                      = var.user_pool_region
  user_pool_id                = aws_cognito_user_pool.this.id
  client_id                   = aws_cognito_user_pool_client.public_client.id
  use_cognito_provided_values = true
}
