# terraform-aws-flagscript-headless-distribution

Terraform module that creates a private, CloudFront-fronted S3 origin for a headless (static) website, following reasonable AWS defaults. It can also run a warm standby origin in a second region.

## Features

- **CloudFront distribution** with HTTPS only (redirect), TLS 1.2+, IPv6, compression and an optional custom 404 page.
- **ACM certificate** for the site domain, requested in `us-east-1` (as CloudFront requires) with DNS validation.
- **Private S3 origin(s)** reached only through Origin Access Control (OAC). Public access is fully blocked and the bucket policy is scoped to this distribution.
- **Optional multi-region failover.** Set `s3_origin_backup_region` to create a second bucket, replicate one way from primary to backup, and add a CloudFront origin group that fails over on 5xx responses.
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

### Notes

- Replication only copies objects written **after** it's enabled. Use S3 Batch Replication to backfill a backup bucket added to an existing site.
- When you use `bucket_encryption_keys`, supply a key for each region you encrypt. A key in the backup region is used to re-encrypt replicas. Each key policy must also allow the `cloudfront.amazonaws.com` service principal to `kms:Decrypt`, or CloudFront can't read the objects (see the `kms-failover` example).
- Buckets are created with `force_destroy = true` because their contents are build artifacts that can be redeployed.

## Examples

- [basic](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/examples/basic): single-region distribution
- [failover](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/examples/failover): primary and backup origins with replication
- [kms-failover](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/tree/main/examples/kms-failover): failover with customer-managed KMS keys in each region
