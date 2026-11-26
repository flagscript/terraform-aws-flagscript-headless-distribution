# cognito-auth-pool

Submodule that creates a Cognito user pool with managed login pages on a custom domain, for signing members in to sites served by the root module. App clients are added separately with [cognito-auth-client](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/modules/cognito-auth-client), so one pool can serve several sites and apps.

## Features

- **User pool** with email sign-in, self-service sign-up, email verification and optional authenticator-app MFA.
- **Managed login pages** on your own domain (for example `auth.example.com`), with an ACM certificate in `us-east-1` and Route 53 records.
- **Groups** for controlling access to member-only content through the `cognito:groups` token claim.
- **Login with Amazon** (optional) as a social identity provider, with its email and name mapped to the user's attributes.
- **Sign in with Apple** (optional) as a social identity provider, with its email, verified-email status and first and last names mapped to the user's attributes.
- **Sign in with Google** (optional) as a social identity provider, with its email, verified-email status and names mapped to the user's attributes.

## Usage

```hcl
module "auth" {
  source  = "flagscript/flagscript-headless-distribution/aws//modules/cognito-auth-pool"
  version = "~> 1.11"

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

  # Optional: leave out (or null) to disable Sign in with Apple
  login_with_apple = {
    client_id   = "com.example.members.login" # Services ID
    key_id      = var.apple_key_id
    private_key = var.apple_private_key # contents of the .p8 file
    team_id     = var.apple_team_id
  }

  # Optional: leave out (or null) to disable Sign in with Google
  login_with_google = {
    client_id     = var.google_client_id
    client_secret = var.google_client_secret
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
- **Sign in with Apple setup:** this needs a paid Apple Developer account. In [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list), enable **Sign in with Apple** on an App ID. Then create a **Services ID**, which is the `client_id`. Configure it with your pool's domain (`auth.example.com`) and its IdP response path as a **Return URL** (`https://auth.example.com/oauth2/idpresponse`). Create a **Key** with Sign in with Apple enabled and download the `.p8` file, which Apple lets you download only once. Pass its contents as `private_key`, with its key ID and your team ID. Cognito signs its own client secret from the key, so there's no secret to copy. The variable is sensitive, but the key is still stored in Terraform state.
- **Apple names and private relay emails:** Apple sends a user's name only on their first sign-in. Users can also hide their email behind an `@privaterelay.appleid.com` address. Cognito's emails to those addresses are dropped unless the sending domain is registered in Apple's Private Email Relay settings, which isn't possible with Cognito's default email sender.
- **Sign in with Google setup:** in the [Google Auth Platform](https://console.cloud.google.com/auth/overview), create a **Web application** OAuth client and pass its client ID and secret in `login_with_google`. Add your pool's domain as an **Authorized JavaScript origin** (`https://auth.example.com`) and its IdP response path as an **Authorized redirect URI** (`https://auth.example.com/oauth2/idpresponse`). Under **Branding**, add the parent domain (`example.com`) as an authorized domain. Under **Audience**, publish the app to production, or only the test users you list can sign in. The variable is sensitive, but the secret is still stored in Terraform state.
- **Enabling a provider per client:** adding a provider to the pool doesn't show it on any sign-in page by itself. Each client opts in through its `identity_provider_names` input.
- **Accounts aren't linked across providers:** someone who signs in with a password, Amazon, Apple and Google using the same email gets a separate user for each, and each user needs its own group membership.
- **Upgrading from 1.6:** the app client moved to `cognito-auth-client`. See that submodule's notes for the `moved` blocks that keep your existing client and secret.
