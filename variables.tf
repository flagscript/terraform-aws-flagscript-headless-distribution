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

variable "github_deployment_target" {
  default     = "main"
  description = "The branch or environment to deploy to. Keyword 'all' may be used for a wildcard."
  type        = string
}

variable "github_deployment_type" {
  default     = "branch"
  description = "Whether github actions should deploy on branch or environment. All may be used for a global wildcard."
  type        = string

  validation {
    condition     = contains(["all", "branch", "environment"], var.github_deployment_type)
    error_message = "Variable github_deployment_type must be an allowed value"
  }
}

variable "github_repository" {
  default     = ""
  description = "The github repository to push the website."
  type        = string
}

variable "use_github_actions" {
  default     = false
  description = "Whether or not to setup github actions deployment."
  type        = bool
}
