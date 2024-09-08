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

# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
variable "default_root_object" {
  default     = "index.html"
  description = "Object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  type        = string
}

variable "deploy_test_index" {
  default     = false
  description = "Whether or not to create a test index.html file."
  type        = bool
}
