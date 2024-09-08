locals {
  normalized_origin = replace(var.domain, ".", "-")
  common_tags = {
    "github:module:repository" = "terraform-aws-flagscript-headless-distribution"
    "terraform:module"         = "flagscript-headless-distribution"
  }
}
