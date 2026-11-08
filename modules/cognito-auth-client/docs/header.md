# cognito-auth-client

Submodule that adds one app client, with matching managed login branding, to an existing Cognito user pool. Call it once per site or app to attach several clients to one pool, such as the one created by [cognito-auth-pool](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/modules/cognito-auth-pool).

Each client is either **public**, for sign-in from browser code, or **confidential**, for sign-in handled server-side, such as a Lambda@Edge function that checks sign-in before CloudFront serves protected pages.

## Features

- **App client** using the OAuth authorization code flow, with the `openid`, `email` and `profile` scopes and token revocation.
- **Public or confidential** through `client_type`: public clients have no secret, and confidential clients get a client secret.
- **Managed login branding** for the client, using Cognito's default look. Under managed login, each client needs its own branding style.
- **Token lifetimes** for ID, access and refresh tokens, set per client.
- **Social sign-in** (optional): offer the pool's social identity providers, such as Login with Amazon or Google, alongside Cognito accounts.

## Choosing a client type

| | `public` | `confidential` (default) |
|---|---|---|
| Use for | Sign-in from browser code, such as a single-page app | Sign-in handled server-side, such as a Lambda@Edge function |
| Client secret | None (`client_secret` output is `null`) | Generated |
| Managed login pages | Yes, with the code flow and PKCE | Yes, with the code flow and the secret |
| Custom sign-in forms (SRP, e.g. Amplify) | Allowed (`ALLOW_USER_SRP_AUTH`) | Not allowed |
| Refresh tokens | Allowed | Allowed |

A browser can't keep a secret, so a public client relies on PKCE instead. Neither type allows plain password sign-in through the Cognito API.

## Usage

Create the pool once, then add a client for each site:

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
```

### Public client (browser sign-in)

```hcl
module "app_client" {
  source  = "flagscript/flagscript-headless-distribution/aws//modules/cognito-auth-client"
  version = "~> 1.7"

  providers = {
    aws = aws.cognito
  }

  callback_urls    = ["https://app.example.com/callback", "http://localhost:3000/callback"]
  client_name      = "app"
  client_type      = "public"
  logout_urls      = ["https://app.example.com/"]
  user_pool_id     = module.auth.user_pool_id
  user_pool_region = "us-east-1"

  # Optional: offer the pool's social providers (e.g. Login with Amazon or Google)
  identity_provider_names = module.auth.identity_provider_names

  # Create the branding only after the pool's login domain exists
  depends_on = [module.auth]
}
```

Give your app `module.app_client.client_id`, `module.auth.user_pool_id` and `module.auth.user_pool_domain_url`.

### Confidential client (Lambda@Edge)

```hcl
module "members_site_client" {
  source  = "flagscript/flagscript-headless-distribution/aws//modules/cognito-auth-client"
  version = "~> 1.7"

  providers = {
    aws = aws.cognito
  }

  # Must match the edge function's redirect path
  callback_urls    = ["https://members.example.com/parseauth"]
  client_name      = "members-site"
  logout_urls      = ["https://members.example.com/"]
  user_pool_id     = module.auth.user_pool_id
  user_pool_region = "us-east-1"

  # Create the branding only after the pool's login domain exists
  depends_on = [module.auth]
}
```

`client_type` defaults to `confidential`, so it can be left out here.

Pass the pool and client outputs to the edge function that enforces sign-in. For example, with [disney/terraform-aws-lambda-at-edge-cognito-authentication](https://github.com/disney/terraform-aws-lambda-at-edge-cognito-authentication):

```hcl
module "members_site_edge_auth" {
  source = "github.com/disney/terraform-aws-lambda-at-edge-cognito-authentication?ref=<commit-sha>"

  name                                = "members-site-edge-auth"
  cognito_user_pool_id                = module.auth.user_pool_id
  cognito_user_pool_region            = "us-east-1"
  cognito_user_pool_domain            = "auth.example.com"
  cognito_user_pool_app_client_id     = module.members_site_client.client_id
  cognito_user_pool_app_client_secret = module.members_site_client.client_secret

  # Keeps the secret in KMS-encrypted SSM instead of the code package
  lambda_config_mode = "hybrid"
}
```

Attach the function's `qualified_arn` to the distribution's cache behavior as a `viewer-request` Lambda function association.

### Providers

This submodule uses the **default** `aws` provider, not an alias. Pass the provider for the account that owns the user pool, for example `providers = { aws = aws.cognito }`. Resources set `region` per resource from `user_pool_region`, so the provider's own region doesn't matter.

### Notes

- **Changing `client_type` replaces the client:** Cognito can't add or remove a secret on an existing client. Switching types creates a new client with a new ID (and secret), so update anything that uses the old ones.
- **Ordering with the pool:** the branding style needs the pool's managed login domain. When the pool and client are created in the same apply, add `depends_on = [module.auth]` (or whatever you named the pool module) so the client waits for the domain.
- **Callback and logout URLs:** each URL must use `https://` (or `http://localhost` for local development) and must not contain a fragment (`#`). Callback URLs must exactly match your app's callback or the edge function's redirect path, or Cognito rejects the redirect after sign-in.
- **Client secret in state:** for confidential clients, the secret is stored in Terraform state, and the `client_secret` output is marked sensitive. Use an encrypted, access-controlled state backend.
- **Identity providers:** Cognito user accounts (`COGNITO`) are always enabled. Add social providers with `identity_provider_names`, which the managed login pages then show as sign-in buttons. Pass `module.auth.identity_provider_names` rather than typing names such as `"LoginWithAmazon"`: the reference makes Terraform create the provider before the client, and a typed name that doesn't exist on the pool fails at apply.
- **Upgrading from 1.6:** in 1.6 the client lived in `cognito-auth-pool`. Add `moved` blocks in your root configuration to keep the existing client, its ID and its secret, instead of replacing them. Leave `client_type` as `confidential`, since the 1.6 client had a secret:

  ```hcl
  moved {
    from = module.auth.aws_cognito_user_pool_client.edge
    to   = module.members_site_client.aws_cognito_user_pool_client.this
  }

  moved {
    from = module.auth.aws_cognito_managed_login_branding.managed_login_pages
    to   = module.members_site_client.aws_cognito_managed_login_branding.managed_login_pages
  }
  ```
