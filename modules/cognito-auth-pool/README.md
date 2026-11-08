<!-- BEGIN_TF_DOCS -->
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

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.16 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.72 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws.cognito"></a> [aws.cognito](#provider\_aws.cognito) | >= 6.72 |
| <a name="provider_aws.dns"></a> [aws.dns](#provider\_aws.dns) | >= 6.72 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_acm_certificate.custom_domain_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.custom_domain_certificate_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cognito_identity_provider.amazon](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_provider) | resource |
| [aws_cognito_identity_provider.google](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_provider) | resource |
| [aws_cognito_user_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_group) | resource |
| [aws_cognito_user_pool.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [aws_route53_record.cloudfront_a_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cloudfront_aaaa_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.custom_domain_certificate_validation_records](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | Id of the hosted zone to hold the route 53 records. | `string` | n/a | yes |
| <a name="input_user_pool_custom_domain"></a> [user\_pool\_custom\_domain](#input\_user\_pool\_custom\_domain) | Custom domain for the hosted login. | `string` | n/a | yes |
| <a name="input_user_pool_name"></a> [user\_pool\_name](#input\_user\_pool\_name) | Name of the user pool. | `string` | n/a | yes |
| <a name="input_user_pool_region"></a> [user\_pool\_region](#input\_user\_pool\_region) | AWS region for the user pool. | `string` | n/a | yes |
| <a name="input_acm_key_algorithm"></a> [acm\_key\_algorithm](#input\_acm\_key\_algorithm) | Specifies the algorithm of the public and private key pair that your Amazon issued certificate uses to encrypt data. | `string` | `"EC_prime256v1"` | no |
| <a name="input_groups"></a> [groups](#input\_groups) | Map of groups to create with their descriptions. The site gates member-only pages on the cognito:groups claim, so a self-registered account sees nothing private until someone adds it to a group. | `map(string)` | `{}` | no |
| <a name="input_login_with_amazon"></a> [login\_with\_amazon](#input\_login\_with\_amazon) | Login with Amazon security profile credentials. Leave null to disable. | <pre>object({<br/>    client_id     = string<br/>    client_secret = string<br/>  })</pre> | `null` | no |
| <a name="input_login_with_google"></a> [login\_with\_google](#input\_login\_with\_google) | Google OAuth web client credentials. Leave null to disable. | <pre>object({<br/>    client_id     = string<br/>    client_secret = string<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to merge into module tags. | `map(string)` | `{}` | no |
| <a name="input_user_pool_deletion_protection"></a> [user\_pool\_deletion\_protection](#input\_user\_pool\_deletion\_protection) | Block deletion of the user pool. Deleting it deletes every member account. | `bool` | `true` | no |
| <a name="input_user_pool_mfa_configuration"></a> [user\_pool\_mfa\_configuration](#input\_user\_pool\_mfa\_configuration) | OFF, OPTIONAL (members may enrol an authenticator app) or ON. | `string` | `"OPTIONAL"` | no |
| <a name="input_user_pool_tier"></a> [user\_pool\_tier](#input\_user\_pool\_tier) | Cognito feature plan. ESSENTIALS is needed for the managed login branding editor. | `string` | `"ESSENTIALS"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_identity_provider_names"></a> [identity\_provider\_names](#output\_identity\_provider\_names) | Names of the social identity providers on this pool, for the client's supported\_identity\_providers. |
| <a name="output_user_pool_arn"></a> [user\_pool\_arn](#output\_user\_pool\_arn) | Cognito user pool ARN. |
| <a name="output_user_pool_domain_url"></a> [user\_pool\_domain\_url](#output\_user\_pool\_domain\_url) | Base URL of the managed login pages, e.g. https://auth.example.com. |
| <a name="output_user_pool_endpoint"></a> [user\_pool\_endpoint](#output\_user\_pool\_endpoint) | Cognito user pool endpoint. |
| <a name="output_user_pool_id"></a> [user\_pool\_id](#output\_user\_pool\_id) | Cognito user pool ID. |
| <a name="output_user_pool_issuer_url"></a> [user\_pool\_issuer\_url](#output\_user\_pool\_issuer\_url) | OIDC issuer for validating tokens on the website/API. |

## Contributing

Commits follow [Conventional Commits](https://www.conventionalcommits.org/), which commitlint enforces through lefthook. Releases and the changelog are generated by semantic-release when changes merge to `main`.

The documentation tables above are generated by [terraform-docs](https://terraform-docs.io/) on pre-commit. To change the surrounding text, edit `docs/header.md` or `docs/footer.md` (or `modules/<name>/docs/header.md` for a submodule), not this README.

## License

MIT licensed. See [LICENSE](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/blob/main/LICENSE).
<!-- END_TF_DOCS -->
