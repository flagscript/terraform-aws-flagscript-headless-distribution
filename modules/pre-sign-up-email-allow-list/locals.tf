locals {
  # Aws
  deployment_regions = compact([var.user_pool_region, var.user_pool_replication_region])
  # Resources
  title_user_pool_name = replace(title(var.user_pool_name), "-", "")
  # Tags
  common_tags = merge(
    {
      "terraform:module:repository" = "https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/modules/pre-sign-up-email-allow-list"
      "terraform:module"            = "terraform-aws-flagscript-headless-distribution//modules/pre-sign-up-email-allow-list"
    },
    var.tags
  )
}
