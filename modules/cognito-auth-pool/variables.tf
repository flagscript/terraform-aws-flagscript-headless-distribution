# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
variable "callback_urls" {
  description = "URLs Cognito may redirect to after sign-in, e.g. https://www.example.com/auth/callback."
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

variable "hosted_zone_id" {
  description = "Id of the hosted zone to hold the route 53 records."
  type        = string
}

variable "user_pool_name" {
  description = "Name of the user pool."
  type        = string
}

variable "user_pool_region" {
  description = "AWS region for the user pool."
  type        = string
}

variable "user_pool_custom_domain" {
  description = "Custom domain for the hosted login."
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

variable "acm_key_algorithm" {
  default     = "EC_prime256v1"
  description = "Specifies the algorithm of the public and private key pair that your Amazon issued certificate uses to encrypt data."
  type        = string

  validation {
    condition     = contains(["EC_prime256v1", "EC_secp384r1", "RSA_2048"], var.acm_key_algorithm)
    error_message = "Variable acm_key_algorithm is not a valid selection."
  }
}

variable "groups" {
  default     = {}
  description = "Map of groups to create with their descriptions. The site gates member-only pages on the cognito:groups claim, so a self-registered account sees nothing private until someone adds it to a group."
  type        = map(string)
}

variable "logout_urls" {
  default     = []
  description = "URLs Cognito may redirect to after sign-out."
  type        = list(string)
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

variable "tags" {
  default     = {}
  description = "Additional tags to merge into module tags."
  type        = map(string)
}


variable "user_pool_mfa_configuration" {
  default     = "OPTIONAL"
  description = "OFF, OPTIONAL (members may enrol an authenticator app) or ON."
  type        = string

  validation {
    condition     = contains(["OFF", "OPTIONAL", "ON"], var.user_pool_mfa_configuration)
    error_message = "mfa_configuration must be OFF, OPTIONAL or ON."
  }
}

variable "user_pool_deletion_protection" {
  description = "Block deletion of the user pool. Deleting it deletes every member account."
  type        = bool
  default     = true
}

variable "user_pool_tier" {
  description = "Cognito feature plan. ESSENTIALS is needed for the managed login branding editor."
  type        = string
  default     = "ESSENTIALS"

  validation {
    condition     = contains(["ESSENTIALS", "PLUS"], var.user_pool_tier)
    error_message = "user_pool_tier must be ESSENTIALS or PLUS."
  }
}
