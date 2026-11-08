<!-- BEGIN_TF_DOCS -->
# edge-auth-client

Submodule that adds a confidential app client, with matching managed login branding, to an existing Cognito user pool. It's meant for a Lambda@Edge function that checks sign-in before CloudFront serves protected pages. Call it once per protected site to attach several clients to one pool, such as the one created by [cognito-auth-pool](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/modules/cognito-auth-pool).

## Features

- **Confidential app client** with a client secret. It uses the OAuth authorization code flow. Users sign in on the managed login pages, and the client doesn't allow direct password sign-in through the Cognito API.
- **Managed login branding** for the client, using Cognito's default look. Under managed login, each client needs its own branding style.
- **Token lifetimes** for ID, access and refresh tokens, set per client.

## Usage

```hcl
module "auth" {
  source  = "flagscript/flagscript-headless-distribution/aws//modules/cognito-auth-pool"
  version = "~> 1.7"

  providers = {
    aws.cognito = aws.cognito
    aws.dns     = aws.dns
  }

  hosted_zone_id          = "Z0123456789EXAMPLE"
  user_pool_custom_domain = "auth.example.com"
  user_pool_name          = "example-members"
  user_pool_region        = "us-east-1"
}

module "members_site_client" {
  source  = "flagscript/flagscript-headless-distribution/aws//modules/edge-auth-client"
  version = "~> 1.7"

  providers = {
    aws = aws.cognito
  }

  # Must match the edge function's redirect path
  callback_urls    = ["https://members.example.com/parseauth"]
  edge_client_name = "members-site"
  logout_urls      = ["https://members.example.com/"]
  user_pool_id     = module.auth.user_pool_id
  user_pool_region = "us-east-1"

  # Create the branding only after the pool's login domain exists
  depends_on = [module.auth]
}
```

Add another `edge-auth-client` call, with its own `edge_client_name` and callback URLs, for each additional protected site.

### Connecting a Lambda@Edge function

Pass the pool and client outputs to the edge function that enforces sign-in. For example, with [disney/terraform-aws-lambda-at-edge-cognito-authentication](https://github.com/disney/terraform-aws-lambda-at-edge-cognito-authentication):

```hcl
module "members_site_edge_auth" {
  source = "github.com/disney/terraform-aws-lambda-at-edge-cognito-authentication?ref=<commit-sha>"

  name                                = "members-site-edge-auth"
  cognito_user_pool_id                = module.auth.user_pool_id
  cognito_user_pool_region            = "us-east-1"
  cognito_user_pool_domain            = "auth.example.com"
  cognito_user_pool_app_client_id     = module.members_site_client.edge_client_id
  cognito_user_pool_app_client_secret = module.members_site_client.edge_client_secret

  # Keeps the secret in KMS-encrypted SSM instead of the code package
  lambda_config_mode = "hybrid"
}
```

Attach the function's `qualified_arn` to the distribution's cache behavior as a `viewer-request` Lambda function association.

### Providers

This submodule uses the **default** `aws` provider, not an alias. Pass the provider for the account that owns the user pool, for example `providers = { aws = aws.cognito }`. Resources set `region` per resource from `user_pool_region`, so the provider's own region doesn't matter.

### Notes

- **Ordering with the pool:** the branding style needs the pool's managed login domain. When the pool and client are created in the same apply, add `depends_on = [module.auth]` (or whatever you named the pool module) so the client waits for the domain.
- **Callback and logout URLs:** each URL must use `https://` (or `http://localhost` for local development) and must not contain a fragment (`#`). Callback URLs must match the edge function's redirect path, or Cognito rejects the redirect after sign-in.
- **Client secret in state:** the client secret is stored in Terraform state, and the `edge_client_secret` output is marked sensitive. Use an encrypted, access-controlled state backend.
- **Identity providers:** the client currently supports Cognito user accounts only (`COGNITO`).
- **Upgrading from 1.6:** in 1.6 the client lived in `cognito-auth-pool`. Add `moved` blocks in your root configuration to keep the existing client, its ID and its secret, instead of replacing them:

  ```hcl
  moved {
    from = module.auth.aws_cognito_user_pool_client.edge
    to   = module.members_site_client.aws_cognito_user_pool_client.edge
  }

  moved {
    from = module.auth.aws_cognito_managed_login_branding.managed_login_pages
    to   = module.members_site_client.aws_cognito_managed_login_branding.managed_login_pages
  }
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

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cognito_managed_login_branding.managed_login_pages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_managed_login_branding) | resource |
| [aws_cognito_user_pool_client.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_callback_urls"></a> [callback\_urls](#input\_callback\_urls) | URLs Cognito may redirect to after sign-in, e.g. https://www.example.com/auth/callback. This must match the edge function’s redirect path. | `list(string)` | n/a | yes |
| <a name="input_edge_client_name"></a> [edge\_client\_name](#input\_edge\_client\_name) | Name of the Cognito user pool client. | `string` | n/a | yes |
| <a name="input_user_pool_id"></a> [user\_pool\_id](#input\_user\_pool\_id) | ID of the Cognito user pool. | `string` | n/a | yes |
| <a name="input_user_pool_region"></a> [user\_pool\_region](#input\_user\_pool\_region) | AWS region for the user pool. | `string` | n/a | yes |
| <a name="input_access_token_validity_minutes"></a> [access\_token\_validity\_minutes](#input\_access\_token\_validity\_minutes) | Lifetime of ID and access tokens. | `number` | `60` | no |
| <a name="input_logout_urls"></a> [logout\_urls](#input\_logout\_urls) | URLs Cognito may redirect to after sign-out. | `list(string)` | `[]` | no |
| <a name="input_public_auth_client"></a> [public\_auth\_client](#input\_public\_auth\_client) | Whether the client is a public authentication client. | `bool` | `false` | no |
| <a name="input_refresh_token_validity_days"></a> [refresh\_token\_validity\_days](#input\_refresh\_token\_validity\_days) | How long a member stays signed in without re-entering credentials. | `number` | `30` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | Cognito user pool client ID. |
| <a name="output_client_secret"></a> [client\_secret](#output\_client\_secret) | Cognito user pool client secret. |

## Contributing

Commits follow [Conventional Commits](https://www.conventionalcommits.org/), which commitlint enforces through lefthook. Releases and the changelog are generated by semantic-release when changes merge to `main`.

The documentation tables above are generated by [terraform-docs](https://terraform-docs.io/) on pre-commit. To change the surrounding text, edit `docs/header.md` or `docs/footer.md` (or `modules/<name>/docs/header.md` for a submodule), not this README.

## License

MIT licensed. See [LICENSE](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/blob/main/LICENSE).
<!-- END_TF_DOCS -->