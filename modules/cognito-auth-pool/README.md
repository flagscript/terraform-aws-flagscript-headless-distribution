<!-- BEGIN_TF_DOCS -->
# cognito-auth-pool

Submodule that creates a Cognito user pool with managed login pages on a custom domain, for signing members in to a site served by the root module.

## Features

- **User pool** with email sign-in, self-service sign-up, email verification and optional authenticator-app MFA.
- **Public app client** using the OAuth authorization code flow with no client secret, for a browser-based site. Use PKCE in your sign-in code.
- **Managed login pages** on your own domain (for example `auth.example.com`), with an ACM certificate in `us-east-1` and Route 53 records.
- **Groups** for controlling access to member-only content through the `cognito:groups` token claim.

## Usage

```hcl
module "auth" {
  source  = "flagscript/flagscript-headless-distribution/aws//modules/cognito-auth-pool"
  version = "~> 1.5"

  providers = {
    aws.cognito = aws.cognito
    aws.dns     = aws.dns
  }

  callback_urls           = ["https://www.example.com/auth/callback"]
  hosted_zone_id          = "Z0123456789EXAMPLE"
  user_pool_custom_domain = "auth.example.com"
  user_pool_name          = "example-members"
  user_pool_region        = "us-east-1"

  groups = {
    members = "Can view member-only pages."
  }
}
```

### Providers

| Alias | Purpose |
|-------|---------|
| `aws.cognito` | Account that owns the user pool, app client and ACM certificate. Resources set `region` per resource, so this provider's region doesn't matter. |
| `aws.dns` | Account that owns the Route 53 hosted zone identified by `hosted_zone_id`. It can be the same provider as `aws.cognito`. |

### Notes

- **Parent domain A record:** Cognito only creates a custom domain such as `auth.example.com` if the **parent** domain (`example.com`) already resolves with an A record. Create that record first (for example, point the apex at your site's distribution), or the domain step fails.
- **Callback URLs:** each URL must use `https://` (or `http://localhost` for local development) and must not contain a fragment (`#`).
- **Deletion protection** is on by default. Deleting the pool deletes every member account, so turn `user_pool_deletion_protection` off deliberately before a destroy.
- **Schema changes:** only `email` is a required attribute. Changing the schema later replaces the pool and every account in it.

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
| [aws_cognito_managed_login_branding.managed_login_pages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_managed_login_branding) | resource |
| [aws_cognito_user_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_group) | resource |
| [aws_cognito_user_pool.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.public_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [aws_route53_record.cloudfront_a_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cloudfront_aaaa_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.custom_domain_certificate_validation_records](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_callback_urls"></a> [callback\_urls](#input\_callback\_urls) | URLs Cognito may redirect to after sign-in, e.g. https://www.example.com/auth/callback. | `list(string)` | n/a | yes |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | Id of the hosted zone to hold the route 53 records. | `string` | n/a | yes |
| <a name="input_user_pool_custom_domain"></a> [user\_pool\_custom\_domain](#input\_user\_pool\_custom\_domain) | Custom domain for the hosted login. | `string` | n/a | yes |
| <a name="input_user_pool_name"></a> [user\_pool\_name](#input\_user\_pool\_name) | Name of the user pool. | `string` | n/a | yes |
| <a name="input_user_pool_region"></a> [user\_pool\_region](#input\_user\_pool\_region) | AWS region for the user pool. | `string` | n/a | yes |
| <a name="input_access_token_validity_minutes"></a> [access\_token\_validity\_minutes](#input\_access\_token\_validity\_minutes) | Lifetime of ID and access tokens. | `number` | `60` | no |
| <a name="input_acm_key_algorithm"></a> [acm\_key\_algorithm](#input\_acm\_key\_algorithm) | Specifies the algorithm of the public and private key pair that your Amazon issued certificate uses to encrypt data. | `string` | `"EC_prime256v1"` | no |
| <a name="input_groups"></a> [groups](#input\_groups) | Map of groups to create with their descriptions. The site gates member-only pages on the cognito:groups claim, so a self-registered account sees nothing private until someone adds it to a group. | `map(string)` | `{}` | no |
| <a name="input_logout_urls"></a> [logout\_urls](#input\_logout\_urls) | URLs Cognito may redirect to after sign-out. | `list(string)` | `[]` | no |
| <a name="input_refresh_token_validity_days"></a> [refresh\_token\_validity\_days](#input\_refresh\_token\_validity\_days) | How long a member stays signed in without re-entering credentials. | `number` | `30` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to merge into module tags. | `map(string)` | `{}` | no |
| <a name="input_user_pool_deletion_protection"></a> [user\_pool\_deletion\_protection](#input\_user\_pool\_deletion\_protection) | Block deletion of the user pool. Deleting it deletes every member account. | `bool` | `true` | no |
| <a name="input_user_pool_mfa_configuration"></a> [user\_pool\_mfa\_configuration](#input\_user\_pool\_mfa\_configuration) | OFF, OPTIONAL (members may enrol an authenticator app) or ON. | `string` | `"OPTIONAL"` | no |
| <a name="input_user_pool_tier"></a> [user\_pool\_tier](#input\_user\_pool\_tier) | Cognito feature plan. ESSENTIALS is needed for the managed login branding editor. | `string` | `"ESSENTIALS"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_public_client_id"></a> [public\_client\_id](#output\_public\_client\_id) | Cognito user pool public client ID. |
| <a name="output_user_pool_arn"></a> [user\_pool\_arn](#output\_user\_pool\_arn) | Cognito user pool ARN. |
| <a name="output_user_pool_domain_url"></a> [user\_pool\_domain\_url](#output\_user\_pool\_domain\_url) | Base URL of the managed login pages, e.g. https://auth.example.com. |
| <a name="output_user_pool_endpoint"></a> [user\_pool\_endpoint](#output\_user\_pool\_endpoint) | Cognito user pool endpoint. |
| <a name="output_user_pool_id"></a> [user\_pool\_id](#output\_user\_pool\_id) | Cognito user pool ID. |
| <a name="output_user_pool_issuer_url"></a> [user\_pool\_issuer\_url](#output\_user\_pool\_issuer\_url) | OIDC issuer for validating tokens on the website/API. |
<!-- END_TF_DOCS -->