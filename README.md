<!-- BEGIN_TF_DOCS -->
# terraform-aws-flagscript-headless-distribution

Terraform module that creates a private, CloudFront-fronted S3 origin for a headless (static) website, following reasonable AWS defaults. It can also run a warm standby origin in a second region.

## Features

- **CloudFront distribution** with HTTPS only (redirect), TLS 1.2+, IPv6, compression and an optional custom 404 page.
- **ACM certificate** for the site domain, requested in `us-east-1` (as CloudFront requires) with DNS validation.
- **Private S3 origin(s)** reached only through Origin Access Control (OAC). Public access is fully blocked and the bucket policy is scoped to this distribution.
- **Optional multi-region failover.** Set `s3_origin_backup_region` to create a second bucket, replicate one way from primary to backup, and add a CloudFront origin group that fails over on 5xx responses by default.
- **Encryption by default.** SSE-S3 is used unless you pass customer-managed KMS keys per region through `bucket_encryption_keys`. SSE-C is blocked. Replication of KMS-encrypted objects is configured automatically.
- **Versioning and EventBridge notifications** are enabled on every bucket.

## Usage

```hcl
provider "aws" {
  alias  = "dist"
  region = "us-east-1"
}

provider "aws" {
  alias  = "dns"
  region = "us-east-1"
}

module "headless_distribution" {
  source  = "flagscript/flagscript-headless-distribution/aws"
  version = "~> 1.3"

  providers = {
    aws.dist = aws.dist
    aws.dns  = aws.dns
  }

  domain                   = "www.example.com"
  hosted_zone_name         = "example.com"
  s3_origin_primary_region = "us-east-1"

  # Optional: warm standby origin with one-way replication
  s3_origin_backup_region = "us-west-2"
}
```

### Providers

This module requires two aliased AWS providers:

| Alias | Purpose |
|-------|---------|
| `aws.dist` | Account that owns the CloudFront distribution, ACM certificate and S3 origin buckets. Resources that must live in a specific region set `region` per resource, so this provider's region doesn't matter. |
| `aws.dns` | Account that owns the Route 53 hosted zone named in `hosted_zone_name`. It can be the same provider as `aws.dist` when everything lives in one account. |

### Deploying content

Upload your site to the **primary** bucket. Its name is in the `distribution_bucket_name` output, keyed by region (for example `module.headless_distribution.distribution_bucket_name["us-east-1"]`). With failover enabled, the backup bucket is filled by replication. Don't write to it directly.

### Failover tuning

When `s3_origin_backup_region` is set, these inputs control how quickly CloudFront moves to the backup origin:

| Input | Default | Allowed |
|-------|---------|---------|
| `failover_status_codes` | `[500, 502, 503, 504]` | Any of `400, 403, 404, 416, 500, 502, 503, 504` (not empty) |
| `origin_connection_attempts` | `2` | Whole number, 1–3 |
| `origin_connection_timeout` | `5` | Whole number of seconds, 1–10 |

In the worst case, CloudFront waits about attempts × timeout seconds (10 by default) before failing over. Adding `403` or `404` to the status codes also fails over when an object is missing from the primary, but a real missing page is then requested from the backup too.

### Notes

- **Domain:** `domain` must be lowercase and at most 32 characters, so the generated bucket and IAM role names stay within AWS limits.
- **Replication timing:** replication is asynchronous. Most objects copy within seconds to minutes, so right after a deploy the backup can briefly serve older content during a failover.
- **Existing objects:** replication only copies objects written **after** it's enabled. Use S3 Batch Replication to backfill a backup bucket added to an existing site.
- **KMS keys:** with a backup region, `bucket_encryption_keys` must have keys for **both** regions or **neither** (enforced by validation). The backup-region key re-encrypts replicas. Each key policy must also allow the `cloudfront.amazonaws.com` service principal to `kms:Decrypt`, or CloudFront can't read the objects (see the `kms-failover` example).
- **Force destroy:** buckets are created with `force_destroy = true` because their contents are build artifacts that can be redeployed.

## Examples

- [basic](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/examples/basic): single-region distribution
- [failover](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/examples/failover): primary and backup origins with replication
- [kms-failover](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/examples/kms-failover): failover with customer-managed KMS keys in each region

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.16 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.72 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws.dist"></a> [aws.dist](#provider\_aws.dist) | >= 6.72 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_acm_certificate.website_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_cloudfront_cache_policy.default_cache_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_distribution.cloudfront_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.origin_access_control](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_iam_role.distribution_replication_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket.website_distribution_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_notification.website_distribution_bucket_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_policy.website_distribution_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.website_distribution_bucket_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.distribution_replication_primary_to_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.website_distribution_bucket_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.website_distribution_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_domain"></a> [domain](#input\_domain) | The domain of the headless website. | `string` | n/a | yes |
| <a name="input_hosted_zone_name"></a> [hosted\_zone\_name](#input\_hosted\_zone\_name) | Name of the hosted zone to hold the route 53 records. | `string` | n/a | yes |
| <a name="input_s3_origin_primary_region"></a> [s3\_origin\_primary\_region](#input\_s3\_origin\_primary\_region) | The primary region for the S3 origin. | `string` | n/a | yes |
| <a name="input_acm_key_algorithm"></a> [acm\_key\_algorithm](#input\_acm\_key\_algorithm) | Specifies the algorithm of the public and private key pair that your Amazon issued certificate uses to encrypt data. | `string` | `"EC_prime256v1"` | no |
| <a name="input_bucket_encryption_keys"></a> [bucket\_encryption\_keys](#input\_bucket\_encryption\_keys) | Optional KMS keys to use for S3 bucket encryption, keyed by deployment region. | `map(string)` | `{}` | no |
| <a name="input_custom_404_page"></a> [custom\_404\_page](#input\_custom\_404\_page) | Path to the custom 404 page. | `string` | `"/404.html"` | no |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | Object that you want CloudFront to return (for example, index.html) when an end user requests the root URL. | `string` | `"index.html"` | no |
| <a name="input_failover_status_codes"></a> [failover\_status\_codes](#input\_failover\_status\_codes) | HTTP status codes that trigger failover to the backup origin. | `list(number)` | <pre>[<br/>  500,<br/>  502,<br/>  503,<br/>  504<br/>]</pre> | no |
| <a name="input_http_version"></a> [http\_version](#input\_http\_version) | Maximum HTTP version to support on the distribution. | `string` | `"http2"` | no |
| <a name="input_origin_connection_attempts"></a> [origin\_connection\_attempts](#input\_origin\_connection\_attempts) | Number of times CloudFront attempts to connect to the origin. | `number` | `2` | no |
| <a name="input_origin_connection_timeout"></a> [origin\_connection\_timeout](#input\_origin\_connection\_timeout) | Maximum time in seconds that CloudFront waits when trying to establish a connection to the origin. | `number` | `5` | no |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | Price class for this distribution. | `string` | `"PriceClass_All"` | no |
| <a name="input_s3_origin_backup_region"></a> [s3\_origin\_backup\_region](#input\_s3\_origin\_backup\_region) | The backup region for the S3 origin - will be replicated from the primary region. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to merge into module tags. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | ARN for the ACM certificate. |
| <a name="output_distribution_arn"></a> [distribution\_arn](#output\_distribution\_arn) | ARN for the distribution. |
| <a name="output_distribution_bucket_arn"></a> [distribution\_bucket\_arn](#output\_distribution\_bucket\_arn) | Regional map of ARN for the S3 bucket. |
| <a name="output_distribution_bucket_name"></a> [distribution\_bucket\_name](#output\_distribution\_bucket\_name) | Regional map of name for the S3 bucket. |
| <a name="output_distribution_domain_name"></a> [distribution\_domain\_name](#output\_distribution\_domain\_name) | Domain name for the distribution. |
| <a name="output_distribution_hosted_zone_id"></a> [distribution\_hosted\_zone\_id](#output\_distribution\_hosted\_zone\_id) | Hosted zone ID for the distribution. |
| <a name="output_distribution_id"></a> [distribution\_id](#output\_distribution\_id) | Identifier for the distribution. |

## Contributing

Commits follow [Conventional Commits](https://www.conventionalcommits.org/), which commitlint enforces through lefthook. Releases and the changelog are generated by semantic-release when changes merge to `main`.

The documentation tables above are generated by [terraform-docs](https://terraform-docs.io/) on pre-commit. To change the surrounding text, edit `docs/header.md` or `docs/footer.md`, not this README.

## License

MIT licensed. See [LICENSE](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/blob/main/LICENSE).
<!-- END_TF_DOCS -->