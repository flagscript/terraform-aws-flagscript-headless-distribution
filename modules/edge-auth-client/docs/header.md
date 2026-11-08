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
