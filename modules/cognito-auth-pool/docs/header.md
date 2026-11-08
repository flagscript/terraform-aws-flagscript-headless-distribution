# cognito-auth-pool

Submodule that creates a Cognito user pool with managed login pages on a custom domain, for signing members in to sites served by the root module. App clients are added separately with [cognito-auth-client](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/modules/cognito-auth-client), so one pool can serve several sites and apps.

## Features

- **User pool** with email sign-in, self-service sign-up, email verification and optional authenticator-app MFA.
- **Managed login pages** on your own domain (for example `auth.example.com`), with an ACM certificate in `us-east-1` and Route 53 records.
- **Groups** for controlling access to member-only content through the `cognito:groups` token claim.
- **Login with Amazon** (optional) as a social identity provider, with its email and name mapped to the user's attributes.

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

  groups = {
    members = "Can view member-only pages."
  }

  # Optional: leave out (or null) to disable Login with Amazon
  login_with_amazon = {
    client_id     = var.amazon_client_id
    client_secret = var.amazon_client_secret
  }
}
```

Then add an app client for each site or app with [cognito-auth-client](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/modules/cognito-auth-client), passing `module.auth.user_pool_id`. Use a public client for browser sign-in, or a confidential client for Lambda@Edge. To offer the pool's social providers on a client, also pass `identity_provider_names = module.auth.identity_provider_names`.

### Providers

| Alias | Purpose |
|-------|---------|
| `aws.cognito` | Account that owns the user pool and ACM certificate. Resources set `region` per resource, so this provider's region doesn't matter. |
| `aws.dns` | Account that owns the Route 53 hosted zone identified by `hosted_zone_id`. It can be the same provider as `aws.cognito`. |

### Notes

- **Parent domain A record:** Cognito only creates a custom domain such as `auth.example.com` if the **parent** domain (`example.com`) already resolves with an A record. Create that record first (for example, point the apex at your site's distribution), or the domain step fails.
- **Deletion protection** is on by default. Deleting the pool deletes every member account, so turn `user_pool_deletion_protection` off deliberately before a destroy.
- **Schema changes:** only `email` is a required attribute. Changing the schema later replaces the pool and every account in it.
- **Login with Amazon setup:** create a security profile in the [Login with Amazon console](https://developer.amazon.com/loginwithamazon/console/site/lwa/overview.html) and pass its client ID and secret in `login_with_amazon`. In the profile's web settings, add your pool's domain as an **Allowed Origin** (`https://auth.example.com`) and its IdP response path as an **Allowed Return URL** (`https://auth.example.com/oauth2/idpresponse`), or Amazon rejects the redirect. The variable is sensitive, but the secret is still stored in Terraform state.
- **Enabling a provider per client:** adding a provider to the pool doesn't show it on any sign-in page by itself. Each client opts in through its `identity_provider_names` input.
- **Upgrading from 1.6:** the app client moved to `cognito-auth-client`. See that submodule's notes for the `moved` blocks that keep your existing client and secret.
