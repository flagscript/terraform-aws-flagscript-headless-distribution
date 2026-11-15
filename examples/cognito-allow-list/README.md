<!-- BEGIN_TF_DOCS -->
# Cognito allow-list example

A Cognito user pool where only emails on a DynamoDB allow list can sign up, built from the
`cognito-auth-pool` and `pre-sign-up-email-allow-list` submodules.

The two modules feed each other: the pool needs the Lambda's ARN for its pre sign-up
trigger, and the allow list needs the pool's ARN to let Cognito invoke the Lambda.
Terraform orders this per resource (Lambda, then pool, then invoke permission), so it
isn't a cycle **as long as both modules get the pool name from the same plain value**
(`local.user_pool_name` here). Passing `module.user_pool.user_pool_name` to the allow list
instead does create a cycle, because the Lambda's name is built from it.

Once the pool exists, add allowed emails (lowercase) to the table, either with
`aws_dynamodb_table_item` as below or with the AWS CLI.

This example uses local paths so it tracks the code in this repository. From the
Terraform Registry, use:

```hcl
source = "flagscript/flagscript-headless-distribution/aws//modules/cognito-auth-pool"
source = "flagscript/flagscript-headless-distribution/aws//modules/pre-sign-up-email-allow-list"
```

```bash
terraform init
terraform apply
```

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.16 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.72 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.72 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_email_allow_list"></a> [email\_allow\_list](#module\_email\_allow\_list) | ../../modules/pre-sign-up-email-allow-list | n/a |
| <a name="module_user_pool"></a> [user\_pool](#module\_user\_pool) | ../../modules/cognito-auth-pool | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_dynamodb_table_item.allowed_email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table_item) | resource |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_allow_list_table_arn"></a> [allow\_list\_table\_arn](#output\_allow\_list\_table\_arn) | Regional map of ARNs of the DynamoDB allow-list table. |
| <a name="output_allow_list_table_name"></a> [allow\_list\_table\_name](#output\_allow\_list\_table\_name) | Name of the DynamoDB allow-list table. Add allowed emails here. |
| <a name="output_pre_sign_up_lambda_arn"></a> [pre\_sign\_up\_lambda\_arn](#output\_pre\_sign\_up\_lambda\_arn) | Regional map of ARNs of the pre sign-up Lambda. |
| <a name="output_user_pool_arn"></a> [user\_pool\_arn](#output\_user\_pool\_arn) | ARN of the Cognito user pool. |
| <a name="output_user_pool_domain_url"></a> [user\_pool\_domain\_url](#output\_user\_pool\_domain\_url) | Base URL of the managed login pages. |
<!-- END_TF_DOCS -->