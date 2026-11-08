# User Pool
resource "aws_cognito_user_pool" "this" {
  provider                 = aws.cognito
  region                   = var.user_pool_region
  auto_verified_attributes = ["email"]
  deletion_protection      = var.user_pool_deletion_protection ? "ACTIVE" : "INACTIVE"
  mfa_configuration        = var.user_pool_mfa_configuration
  name                     = var.user_pool_name
  user_pool_tier           = var.user_pool_tier
  # Members sign in with their email address; it is also how social account are matched up.
  username_attributes = ["email"]

  tags = merge(
    local.common_tags,
    {
      "Name" = var.user_pool_name
    }
  )

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Self-service sign-up. Access to private pages is controlled by groups.
  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT" # local.use_ses ? "DEVELOPER" : "COGNITO_DEFAULT"
    # from_email_address     = var.ses_from_email
    # source_arn             = var.ses_identity_arn
    # configuration_set      = local.use_ses ? var.ses_configuration_set : null
    # reply_to_email_address = var.reply_to_email
  }

  password_policy {
    minimum_length                   = 10
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  # Only email is required: social providers do not all return first and last
  # names, and a required attribute the provider omits makes sign-in fail.
  # Changing the schema later forces the pool (and every account) to be
  # replaced, so add attributes with care.
  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true

    string_attribute_constraints {
      min_length = 5
      max_length = 254
    }
  }

  username_configuration {
    case_sensitive = false
  }

  dynamic "software_token_mfa_configuration" {
    for_each = var.user_pool_mfa_configuration == "OFF" ? [] : [1]
    content {
      enabled = true
    }
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  # lifecycle {
  #   precondition {
  #     condition     = !local.use_ses || var.ses_identity_arn != null
  #     error_message = "ses_identity_arn is required when ses_from_email is set."
  #   }
  # }
}
