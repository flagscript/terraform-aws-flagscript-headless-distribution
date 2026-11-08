# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
variable "callback_urls" {
  description = "URLs Cognito may redirect to after sign-in, e.g. https://www.example.com/auth/callback. This must match the edge function’s redirect path."
  type        = list(string)

  validation {
    condition     = length(var.callback_urls) > 0
    error_message = "callback_urls needs at least one URL, because the client uses the OAuth code flow."
  }

  validation {
    condition = alltrue([
      for url in var.callback_urls :
      can(regex("^(https://[^/#?[:space:]]+|http://localhost(:[0-9]+)?)(/[^#[:space:]]*)?$", url))
    ])
    error_message = "Each callback URL must start with https:// (or http://localhost for local development) and must not contain a fragment (#)."
  }
}

variable "edge_client_name" {
  description = "Name of the Cognito user pool client."
  type        = string
}

variable "user_pool_id" {
  description = "ID of the Cognito user pool."
  type        = string
}

variable "user_pool_region" {
  description = "AWS region for the user pool."
  type        = string
}

# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
variable "access_token_validity_minutes" {
  description = "Lifetime of ID and access tokens."
  type        = number
  default     = 60

  validation {
    condition     = var.access_token_validity_minutes >= 5 && var.access_token_validity_minutes <= 1440
    error_message = "access_token_validity_minutes must be between 5 and 1440."
  }
}

variable "logout_urls" {
  default     = []
  description = "URLs Cognito may redirect to after sign-out."
  type        = list(string)

  validation {
    condition = alltrue([
      for url in var.logout_urls :
      can(regex("^(https://[^/#?[:space:]]+|http://localhost(:[0-9]+)?)(/[^#[:space:]]*)?$", url))
    ])
    error_message = "Each logout URL must start with https:// (or http://localhost for local development) and must not contain a fragment (#)."
  }
}

variable "public_auth_client" {
  default     = false
  description = "Whether the client is a public authentication client."
  type        = bool
}

variable "refresh_token_validity_days" {
  description = "How long a member stays signed in without re-entering credentials."
  type        = number
  default     = 30

  validation {
    condition     = var.refresh_token_validity_days >= 1 && var.refresh_token_validity_days <= 365
    error_message = "refresh_token_validity_days must be between 1 and 365."
  }
}
