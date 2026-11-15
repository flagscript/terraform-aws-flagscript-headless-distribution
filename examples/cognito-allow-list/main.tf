/**
 * # Cognito allow-list example
 *
 * A Cognito user pool where only emails on a DynamoDB allow list can sign up, built from the
 * `cognito-auth-pool` and `pre-sign-up-email-allow-list` submodules.
 *
 * The two modules feed each other: the pool needs the Lambda's ARN for its pre sign-up
 * trigger, and the allow list needs the pool's ARN to let Cognito invoke the Lambda.
 * Terraform orders this per resource (Lambda, then pool, then invoke permission), so it
 * isn't a cycle **as long as both modules get the pool name from the same plain value**
 * (`local.user_pool_name` here). Passing `module.user_pool.user_pool_name` to the allow list
 * instead does create a cycle, because the Lambda's name is built from it.
 *
 * Once the pool exists, add allowed emails (lowercase) to the table, either with
 * `aws_dynamodb_table_item` as below or with the AWS CLI.
 *
 * This example uses local paths so it tracks the code in this repository. From the
 * Terraform Registry, use:
 *
 * ```hcl
 * source = "flagscript/flagscript-headless-distribution/aws//modules/cognito-auth-pool"
 * source = "flagscript/flagscript-headless-distribution/aws//modules/pre-sign-up-email-allow-list"
 * ```
 *
 * ```bash
 * terraform init
 * terraform apply
 * ```
 */

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "dns"
  region = "us-east-1"
}

locals {
  # Shared by both modules. Don't replace with module.user_pool.user_pool_name (see above).
  user_pool_name   = "example-pool"
  user_pool_region = "us-east-1"
}

module "user_pool" {
  source = "../../modules/cognito-auth-pool"

  providers = {
    aws.cognito = aws
    aws.dns     = aws.dns
  }

  hosted_zone_id          = "Z0123456789EXAMPLE"
  user_pool_custom_domain = "auth.example.com"
  user_pool_name          = local.user_pool_name
  user_pool_region        = local.user_pool_region

  user_pool_pre_sign_up_lambda_arn = module.email_allow_list.lambda_function_arn[local.user_pool_region]

  tags = {
    Environment = "example"
  }
}

module "email_allow_list" {
  source = "../../modules/pre-sign-up-email-allow-list"

  user_pool_name   = local.user_pool_name
  user_pool_region = local.user_pool_region
  user_pool_arn = {
    (local.user_pool_region) = module.user_pool.user_pool_arn
  }

  deny_message = "Sign-up is invite-only. Ask an administrator for access."

  tags = {
    Environment = "example"
  }
}

# Seed the allow list. Emails must be stored lowercase.
resource "aws_dynamodb_table_item" "allowed_email" {
  table_name = module.email_allow_list.table_name
  hash_key   = "email"
  item       = jsonencode({ email = { S = "alice@example.com" } })
}
