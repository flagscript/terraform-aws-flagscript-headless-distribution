# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
variable "user_pool_arn" {
  description = "Map of Cognito user pool ARNs by AWS region."
  type        = map(string)
}

variable "user_pool_name" {
  description = "Cognito user pool name to which the allow-list applies."
  type        = string
}

variable "user_pool_region" {
  description = "AWS region for the user pool."
  type        = string
}

# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
variable "deny_message" {
  description = "Message shown when a sign-up is rejected. Cognito displays it as \"PreSignUp failed with error <deny_message>\"."
  type        = string
  default     = "This email is not authorized to sign up."

  validation {
    condition     = length(trimspace(var.deny_message)) > 0 && length(var.deny_message) <= 500
    error_message = "deny_message must be non-empty and at most 500 characters."
  }
}

variable "lambda_application_log_level" {
  default     = "INFO"
  description = "Application log level for the pre auth lambdaLambda."
  type        = string

  validation {
    condition     = contains(["TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL"], var.lambda_application_log_level)
    error_message = "The lambda_application_log_level value must be one of TRACE, DEBUG, INFO, WARN, ERROR, or FATAL."
  }
}

variable "lambda_system_log_level" {
  default     = "INFO"
  description = "System log level for the pre auth lambda."
  type        = string

  validation {
    condition     = contains(["DEBUG", "INFO", "WARN"], var.lambda_system_log_level)
    error_message = "The lambda_system_log_level value must be one of DEBUG, INFO, or WARN."
  }
}

variable "log_retention_days" {
  description = "How long to keep the Lambda's CloudWatch logs."
  type        = number
  default     = 7

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731], var.log_retention_days)
    error_message = "The log_retention_days value must be one of 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, or 731. If you select 0, the events in the log group are always retained and never expire."
  }
}

variable "table_deletion_protection" {
  default     = true
  description = "Protect the allow-list table from being deleted (including by terraform destroy)."
  type        = bool
}

variable "tags" {
  default     = {}
  description = "Additional tags to merge into module tags."
  type        = map(string)
}

variable "user_pool_replication_region" {
  default     = null
  description = "AWS region for the user pool replication."
  type        = string
}
