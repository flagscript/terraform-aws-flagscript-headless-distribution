# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
variable "domain" {
  description = "The domain of the headless website."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9.-]+$", var.domain)) && length(var.domain) < 33
    error_message = "Domain must contain only lowercase letters, numbers, dots, and hyphens and must be less than 33 characters."
  }
}

variable "hosted_zone_name" {
  description = "Name of the hosted zone to hold the route 53 records."
  type        = string
}

variable "s3_origin_primary_region" {
  description = "The primary region for the S3 origin."
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

variable "bucket_encryption_keys" {
  default     = {}
  description = "Optional KMS keys to use for S3 bucket encryption, keyed by deployment region."
  type        = map(string)

  validation {
    condition = (
      var.s3_origin_backup_region == null ||
      contains(keys(var.bucket_encryption_keys), var.s3_origin_primary_region) ==
      contains(keys(var.bucket_encryption_keys), var.s3_origin_backup_region)
    )
    error_message = "When using a backup region, provide KMS keys for both regions or neither."
  }
}

variable "custom_404_page" {
  default     = "/404.html"
  description = "Path to the custom 404 page."
  type        = string
}

variable "default_root_object" {
  default     = "index.html"
  description = "Object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  type        = string
}

variable "failover_status_codes" {
  default     = [500, 502, 503, 504]
  description = "HTTP status codes that trigger failover to the backup origin."
  nullable    = false
  type        = list(number)

  validation {
    condition = alltrue(
      [
        length(var.failover_status_codes) > 0,
        length(setsubtract(var.failover_status_codes, [400, 403, 404, 416, 500, 502, 503, 504])) == 0
      ],
    )
    error_message = "Must contain only 400, 403, 404, 416, 500, 502, 503 or 504 and can not be empty."
  }
}

variable "http_version" {
  default     = "http2"
  description = "Maximum HTTP version to support on the distribution."
  type        = string

  validation {
    condition     = can(regex("^(http1.1|http2|http2and3|http3)$", var.http_version))
    error_message = "Must be acceptable cloudfront http version."
  }
}

variable "price_class" {
  default     = "PriceClass_All"
  description = "Price class for this distribution."
  type        = string
  validation {
    condition     = can(regex("^(PriceClass_All|PriceClass_200|PriceClass_100)$", var.price_class))
    error_message = "Must be acceptable cloudfront price class."
  }
}

variable "origin_connection_attempts" {
  default     = 2
  description = "Number of times CloudFront attempts to connect to the origin."
  type        = number

  validation {
    condition     = var.origin_connection_attempts >= 1 && var.origin_connection_attempts <= 3 && floor(var.origin_connection_attempts) == var.origin_connection_attempts
    error_message = "Must be a whole number between 1 and 3."
  }
}

variable "origin_connection_timeout" {
  default     = 5
  description = "Maximum time in seconds that CloudFront waits when trying to establish a connection to the origin."
  type        = number

  validation {
    condition     = var.origin_connection_timeout >= 1 && var.origin_connection_timeout <= 10 && floor(var.origin_connection_timeout) == var.origin_connection_timeout
    error_message = "Must be a whole number between 1 and 10."
  }
}

variable "s3_origin_backup_region" {
  default     = null
  description = "The backup region for the S3 origin - will be replicated from the primary region."
  type        = string

  validation {
    condition     = var.s3_origin_backup_region == null || var.s3_origin_backup_region != var.s3_origin_primary_region
    error_message = "Backup region must be different from the primary region."
  }
}

variable "tags" {
  default     = {}
  description = "Additional tags to merge into module tags."
  type        = map(string)
}






