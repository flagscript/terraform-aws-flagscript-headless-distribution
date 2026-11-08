# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
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

variable "tags" {
  default     = {}
  description = "Additional tags to merge into module tags."
  type        = map(string)
}

variable "login_with_amazon" {
  default     = null
  description = "Login with Amazon security profile credentials. Leave null to disable."
  sensitive   = true
  type = object({
    client_id     = string
    client_secret = string
  })
}

variable "login_with_google" {
  default     = null
  description = "Google OAuth web client credentials. Leave null to disable."
  sensitive   = true
  type = object({
    client_id     = string
    client_secret = string
  })
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
