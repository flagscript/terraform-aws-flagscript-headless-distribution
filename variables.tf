# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
variable "domain" {
  description = "The domain of the headless website."
  type        = string
}

# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
variable "default_root_object" {
  default     = "index.html"
  description = "Object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  type        = string
}
