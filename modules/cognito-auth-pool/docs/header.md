# cognito-auth-pool

Submodule that creates a Cognito user pool with managed login pages on a custom domain, plus a confidential app client for a Lambda@Edge function that protects a site served by the root module.

## Features

- **User pool** with email sign-in, self-service sign-up, email verification and optional authenticator-app MFA.
- **Confidential app client** with a client secret, for a Lambda@Edge function that checks sign-in before CloudFront serves protected pages. It uses the OAuth authorization code flow. Users sign in on the managed login pages, and the client doesn't allow direct password sign-in through the Cognito API.
- **Managed login pages** on your own domain (for example `auth.example.com`), with an ACM certificate in `us-east-1` and Route 53 records.
- **Groups** for controlling access to member-only content through the `cognito:groups` token claim.

## Usage

```hcl
module "auth" {
  source  = "flagscript/flagscript-headless-distribution/aws//modules/cognito-auth-pool"
  version = "~> 1.6"

  providers = {
    aws.cognito = aws.cognito
    aws.dns     = aws.dns
  }

  # Must match the edge function's redirect path
  callback_urls           = ["https://www.example.com/parseauth"]
  logout_urls             = ["https://www.example.com/"]
  hosted_zone_id          = "Z0123456789EXAMPLE"
  user_pool_custom_domain = "auth.example.com"
  user_pool_name          = "example-members"
  user_pool_region        = "us-east-1"

  groups = {
    members = "Can view member-only pages."
  }
}
```

### Connecting a Lambda@Edge function

Pass the user pool and client outputs to the edge function that enforces sign-in. For example, with [disney/terraform-aws-lambda-at-edge-cognito-authentication](https://github.com/disney/terraform-aws-lambda-at-edge-cognito-authentication):

```hcl
module "edge_auth" {
  source = "github.com/disney/terraform-aws-lambda-at-edge-cognito-authentication?ref=<commit-sha>"

  name                                = "example-edge-auth"
  cognito_user_pool_id                = module.auth.user_pool_id
  cognito_user_pool_region            = "us-east-1"
  cognito_user_pool_domain            = "auth.example.com"
  cognito_user_pool_app_client_id     = module.auth.edge_client_id
  cognito_user_pool_app_client_secret = module.auth.edge_client_secret

  # Keeps the secret in KMS-encrypted SSM instead of the code package
  lambda_config_mode = "hybrid"
}
```

Attach the function's `qualified_arn` to the distribution's cache behavior as a `viewer-request` Lambda function association.

### Providers

| Alias | Purpose |
|-------|---------|
| `aws.cognito` | Account that owns the user pool, app client and ACM certificate. Resources set `region` per resource, so this provider's region doesn't matter. |
| `aws.dns` | Account that owns the Route 53 hosted zone identified by `hosted_zone_id`. It can be the same provider as `aws.cognito`. |

### Notes

- **Parent domain A record:** Cognito only creates a custom domain such as `auth.example.com` if the **parent** domain (`example.com`) already resolves with an A record. Create that record first (for example, point the apex at your site's distribution), or the domain step fails.
- **Callback URLs:** each URL must use `https://` (or `http://localhost` for local development) and must not contain a fragment (`#`). They must match the edge function's redirect path, or Cognito rejects the redirect after sign-in.
- **Client secret in state:** the client secret is stored in Terraform state, and the `edge_client_secret` output is marked sensitive. Use an encrypted, access-controlled state backend.
- **Deletion protection** is on by default. Deleting the pool deletes every member account, so turn `user_pool_deletion_protection` off deliberately before a destroy.
- **Schema changes:** only `email` is a required attribute. Changing the schema later replaces the pool and every account in it.
