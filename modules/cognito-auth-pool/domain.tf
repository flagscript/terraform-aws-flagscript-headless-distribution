# Cognito hosted login domain
resource "aws_cognito_user_pool_domain" "this" {
  provider        = aws.cognito
  region          = var.user_pool_region
  certificate_arn = aws_acm_certificate_validation.custom_domain_certificate_validation.certificate_arn
  domain          = var.user_pool_custom_domain
  # 2 = the current "managed login" pages; 1 = the classic hosted UI.
  managed_login_version = 2
  user_pool_id          = aws_cognito_user_pool.this.id
}
