# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
variable "domain" {
  description = "The domain of the headless website."
  type        = string
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
}

variable "custom_404_page" {
  default     = "/404.html"
  description = "Optional custom 404 page to redirect to."
  type        = string
}

variable "default_root_object" {
  default     = "index.html"
  description = "Object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  type        = string
}

variable "http_version" {
  default     = "http2"
  description = "Maximum HTTP version to support on the distribution. "
  type        = string

  validation {
    condition     = can(regex("^(http1.1|http2|http2and3|http3)$", var.http_version))
    error_message = "Must be acceptible cloudfront http version."
  }
}

variable "price_class" {
  default     = "PriceClass_All"
  description = "Price class for this distribution."
  type        = string
  validation {
    condition     = can(regex("^(PriceClass_All|PriceClass_200|PriceClass_100)$", var.price_class))
    error_message = "Must be acceptible cloudfront price class."
  }
}

variable "s3_origin_backup_region" {
  default     = null
  description = "The backup region for the S3 origin - will be replicated from the primary region."
  type        = string
}

variable "tags" {
  default     = {}
  description = "Additional tags to merge into module tags."
  type        = map(string)
}






