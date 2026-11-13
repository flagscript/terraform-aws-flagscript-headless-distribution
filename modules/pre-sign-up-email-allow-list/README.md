<!-- BEGIN_TF_DOCS -->
# Cognito email allow list

A Terraform module that creates a Cognito **Pre Sign-up** Lambda trigger
(TypeScript compiled to an ES module, `nodejs24.x`) and a DynamoDB allow-list
table. People can only register if their email is in the table. Everyone else,
and any sign-up where the lookup fails, gets rejected.

The compiled Lambda is committed at `lambda/dist/index.mjs`, so using the module
needs only Terraform: no Node.js or build step.

## Usage

```hcl
module "allow_list" {
  source  = "<namespace>/cognito-allow-list/aws"
  version = "~> 1.0"

  name          = "my-app-allow-list"
  user_pool_arn = aws_cognito_user_pool.this.arn
}

resource "aws_cognito_user_pool" "this" {
  # ...
  lambda_config {
    pre_sign_up = module.allow_list.lambda_function_arn
  }
}
```

The module can't attach the trigger to your pool itself (that setting lives on
the `aws_cognito_user_pool` resource), so set `lambda_config.pre_sign_up` as
above. If the pool isn't managed by Terraform, attach it in the console under
**User pool → Extensions → Add Lambda trigger → Sign-up → Pre sign-up**.

## Managing the allow list

Store emails **lowercase**. The handler lowercases and trims the email before the lookup.
Add entries with `aws_dynamodb_table_item` (see the example) or the CLI:

```bash
aws dynamodb put-item --table-name <table_name> --item '{"email": {"S": "alice@example.com"}}'
```

```bash
aws dynamodb delete-item --table-name <table_name> --key '{"email": {"S": "alice@example.com"}}'
```

## Things to know

- Rejected users see `deny_message` with Cognito's own prefix in front, e.g.
  `PreSignUp failed with error This email is not authorized to sign up.` The prefix comes
  from Cognito and can't be changed, so write the message to read well after it. Managed
  login may display the text slightly differently from the API.
- The check runs for all three pre sign-up paths: self sign-up, admin-created users
  (`AdminCreateUser`), and a user's first sign-in through a federated provider (Google,
  SAML, etc.). For federated users, the email comes from the provider's attribute mapping,
  so map the provider's email to the pool's `email` attribute or they'll all be rejected.
- It only gates **creating** an account. Removing an email from the table doesn't affect a
  user who already exists; disable or delete them in the pool (and run
  `admin-user-global-sign-out`) to cut off access.
- A user who signs up with an allowed email can still change their `email` attribute later
  unless you make it immutable for app clients (don't grant write access to `email` in the
  app client's write attributes).

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.16 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.72 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.72 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.lambda_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_dynamodb_table.allow_list_dynamo_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_role.pre_sign_up_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.pre_sign_up_lambda_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.pre_sign_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.cognito_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_user_pool_arn"></a> [user\_pool\_arn](#input\_user\_pool\_arn) | Map of Cognito user pool ARNs by AWS region. | `map(string)` | n/a | yes |
| <a name="input_user_pool_name"></a> [user\_pool\_name](#input\_user\_pool\_name) | Cognito user pool name to which the allow-list applies. | `string` | n/a | yes |
| <a name="input_user_pool_region"></a> [user\_pool\_region](#input\_user\_pool\_region) | AWS region for the user pool. | `string` | n/a | yes |
| <a name="input_deny_message"></a> [deny\_message](#input\_deny\_message) | Message shown when a sign-up is rejected. Cognito displays it as "PreSignUp failed with error <deny\_message>". | `string` | `"This email is not authorized to sign up."` | no |
| <a name="input_lambda_application_log_level"></a> [lambda\_application\_log\_level](#input\_lambda\_application\_log\_level) | Application log level for the pre auth lambdaLambda. | `string` | `"INFO"` | no |
| <a name="input_lambda_system_log_level"></a> [lambda\_system\_log\_level](#input\_lambda\_system\_log\_level) | System log level for the pre auth lambda. | `string` | `"INFO"` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | How long to keep the Lambda's CloudWatch logs. | `number` | `7` | no |
| <a name="input_table_deletion_protection"></a> [table\_deletion\_protection](#input\_table\_deletion\_protection) | Protect the allow-list table from being deleted (including by terraform destroy). | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to merge into module tags. | `map(string)` | `{}` | no |
| <a name="input_user_pool_replication_region"></a> [user\_pool\_replication\_region](#input\_user\_pool\_replication\_region) | AWS region for the user pool replication. | `string` | `null` | no |

## Contributing

Commits follow [Conventional Commits](https://www.conventionalcommits.org/), which commitlint enforces through lefthook. Releases and the changelog are generated by semantic-release when changes merge to `main`.

The documentation tables above are generated by [terraform-docs](https://terraform-docs.io/) on pre-commit. To change the surrounding text, edit `docs/header.md` or `docs/footer.md` (or `modules/<name>/docs/header.md` for a submodule), not this README.

## License

MIT licensed. See [LICENSE](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/blob/main/LICENSE).
<!-- END_TF_DOCS -->
