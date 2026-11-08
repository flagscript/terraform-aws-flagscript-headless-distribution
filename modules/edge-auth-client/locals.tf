locals {
  user_pool_name = data.aws_cognito_user_pool.this.name
  common_tags = merge(
    {
      "terraform:module:repository" = "https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/modules/edge-auth-client"
      "terraform:module"            = "terraform-aws-flagscript-headless-distribution//modules/edge-auth-client"
    },
    var.tags
  )
}
