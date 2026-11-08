locals {
  # Aws locals
  distribution_account_id = data.aws_caller_identity.distribution.account_id
  deployment_regions = concat(
    [var.s3_origin_primary_region],
    var.s3_origin_backup_region != null ? [var.s3_origin_backup_region] : []
  )
  # domains
  normalized_domain = replace(var.domain, ".", "-")
  title_domain      = replace(title(local.normalized_domain), "-", "")
  use_s3_failover   = var.s3_origin_backup_region != null
  common_tags = merge(
    {
      "terraform:module:repository" = "https://github.com/flagscript/terraform-aws-flagscript-headless-distribution"
      "terraform:module"            = "flagscript-headless-distribution"
    },
    var.tags
  )
}
