/**
 * # KMS failover example
 *
 * A failover distribution (primary `us-east-1`, backup `us-west-2`) where each origin
 * bucket is encrypted with a customer-managed KMS key in its own region.
 *
 * Passing `bucket_encryption_keys` makes the module:
 *
 * - set SSE-KMS (with an S3 bucket key) as the default encryption on each bucket
 * - opt the replication rule in to SSE-KMS objects and re-encrypt replicas with the
 *   backup-region key
 * - grant the replication role `kms:Decrypt` on the primary key and `kms:Encrypt` /
 *   `kms:GenerateDataKey` on the backup key, scoped to S3 and these buckets
 *
 * CloudFront reads the objects through Origin Access Control, so each key policy must also
 * allow the `cloudfront.amazonaws.com` service principal to `kms:Decrypt` for this
 * distribution. This example's key policies grant that.
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

locals {
  primary_region = "us-east-1"
  backup_region  = "us-west-2"
}

data "aws_caller_identity" "current" {
  provider = aws.dist
}

data "aws_partition" "current" {
  provider = aws.dist
}

# Key policy: account admin access, plus CloudFront decrypt for distributions in this account.
data "aws_iam_policy_document" "origin_key_policy" {
  provider = aws.dist

  statement {
    sid       = "EnableAccountAdministration"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowCloudFrontOacDecrypt"
    actions   = ["kms:Decrypt"]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_kms_key" "origin" {
  for_each = toset([local.primary_region, local.backup_region])
  provider = aws.dist
  region   = each.key

  description         = "S3 origin encryption key for www.example.com (${each.key})"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.origin_key_policy.json
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
  s3_origin_primary_region = local.primary_region
  s3_origin_backup_region  = local.backup_region

  bucket_encryption_keys = {
    for region, key in aws_kms_key.origin : region => key.arn
  }

  tags = {
    Environment = "example"
  }
}
