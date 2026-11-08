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

  distribution_name        = "example-site"
  domain                   = "www.example.com"
  hosted_zone_id           = "Z0123456789EXAMPLE"
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
| `aws.dns` | Account that owns the Route 53 hosted zone identified by `hosted_zone_id`. It can be the same provider as `aws.dist` when everything lives in one account. |

### Deploying content

Upload your site to the **primary** bucket. Buckets are named `<distribution_name>-distribution-<account_id>-<region>-an` (for example `example-site-distribution-123456789012-us-east-1-an`). The name is also in the `distribution_bucket_name` output, keyed by region (for example `module.headless_distribution.distribution_bucket_name["us-east-1"]`). With failover enabled, the backup bucket is filled by replication. Don't write to it directly.

### Failover tuning

When `s3_origin_backup_region` is set, these inputs control how quickly CloudFront moves to the backup origin:

| Input | Default | Allowed |
|-------|---------|---------|
| `failover_status_codes` | `[500, 502, 503, 504]` | Any of `400, 403, 404, 416, 500, 502, 503, 504` (not empty) |
| `origin_connection_attempts` | `2` | Whole number, 1–3 |
| `origin_connection_timeout` | `5` | Whole number of seconds, 1–10 |

In the worst case, CloudFront waits about attempts × timeout seconds (10 by default) before failing over. Adding `403` or `404` to the status codes also fails over when an object is missing from the primary, but a real missing page is then requested from the backup too.

### Notes

- **Naming:** `distribution_name` names the S3 buckets and the replication IAM role. It must be lowercase letters, numbers and hyphens, start with a letter or number, and be at most 19 characters so the bucket names stay within the 63-character S3 limit. `domain` must be lowercase and at most 63 characters, because it names the Origin Access Control and cache policy.
- **Renaming:** changing `distribution_name` replaces the buckets. With `force_destroy = true` the old buckets and their contents are deleted, so redeploy your site afterwards.
- **Replication timing:** replication is asynchronous. Most objects copy within seconds to minutes, so right after a deploy the backup can briefly serve older content during a failover.
- **Existing objects:** replication only copies objects written **after** it's enabled. Use S3 Batch Replication to backfill a backup bucket added to an existing site.
- **KMS keys:** with a backup region, `bucket_encryption_keys` must have keys for **both** regions or **neither** (enforced by validation). The backup-region key re-encrypts replicas. Each key policy must also allow the `cloudfront.amazonaws.com` service principal to `kms:Decrypt`, or CloudFront can't read the objects (see the `kms-failover` example).
- **Force destroy:** buckets are created with `force_destroy = true` because their contents are build artifacts that can be redeployed.

## Submodules

- [cognito-auth-pool](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/modules/cognito-auth-pool): Cognito user pool with managed login pages on a custom domain, and a confidential app client for Lambda@Edge authentication in front of the distribution

## Examples

- [basic](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/examples/basic): single-region distribution
- [failover](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/examples/failover): primary and backup origins with replication
- [kms-failover](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/examples/kms-failover): failover with customer-managed KMS keys in each region
