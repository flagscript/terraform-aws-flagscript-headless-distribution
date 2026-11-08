/**
 * # Failover example
 *
 * A headless distribution with a primary origin in `us-east-1` and a warm standby in
 * `us-west-2`.
 *
 * - Objects written to the primary bucket are replicated **one way** to the backup bucket,
 *   including delete markers.
 * - CloudFront uses an origin group that retries against the backup origin when the primary
 *   returns `500`, `502`, `503` or `504`.
 *
 * Deploy your site content to the **primary** bucket only. Objects that existed before
 * replication was enabled aren't copied; use S3 Batch Replication to backfill them.
 *
 * ```bash
 * terraform init
 * terraform apply
 * ```
 */

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
  s3_origin_backup_region  = "us-west-2"

  price_class  = "PriceClass_100"
  http_version = "http2and3"

  tags = {
    Environment = "example"
  }
}
