# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
variable "callback_urls" {
  description = "URLs Cognito may redirect to after sign-in. Your app's sign-in callback, or the edge function's redirect path."
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

variable "client_name" {
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

variable "identity_provider_names" {
  default     = []
  description = "Names of the social identity providers to enable for this client."
  type        = list(string)
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

variable "client_type" {
  default     = "confidential"
  description = "public: browser-based sign-in, with no secret and SRP allowed. confidential: server-side sign-in such as LambdaAtEdge, with a client secret. Changing it replaces the client."
  type        = string

  validation {
    condition     = contains(["public", "confidential"], var.client_type)
    error_message = "client_type must be either public or confidential."
  }
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
