/**
 * # Basic example
 *
 * A single-region headless distribution: one private S3 origin in `us-east-1`, served
 * through CloudFront with an ACM certificate for `www.example.com`.
 *
 * Both provider aliases point at the same account here. Point `aws.dns` at a different
 * account if your Route 53 hosted zone lives elsewhere.
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

  domain                   = "www.example.com"
  hosted_zone_id           = "Z0123456789EXAMPLE"
  s3_origin_primary_region = "us-east-1"

  tags = {
    Environment = "example"
  }
}
