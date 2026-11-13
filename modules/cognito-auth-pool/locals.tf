locals {
  # Resources
  deploy_lambdas = length(compact([var.user_pool_pre_sign_up_lambda_arn])) > 0
  # Tags
  common_tags = merge(
    {
      "terraform:module:repository" = "https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/modules/cognito-auth-pool"
      "terraform:module"            = "terraform-aws-flagscript-headless-distribution//modules/cognito-auth-pool"
    },
    var.tags
  )
}
