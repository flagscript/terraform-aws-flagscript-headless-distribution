# Distribution bucket
## Use account-regional namespace
resource "aws_s3_bucket" "website_distribution_bucket" {
  for_each         = toset(local.deployment_regions)
  provider         = aws.dist
  region           = each.key
  bucket           = "${local.title_distribution_name}-distribution-${local.distribution_account_id}-${each.key}-an"
  bucket_namespace = "account-regional"
  force_destroy    = true
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.title_distribution_name}-distribution-${local.distribution_account_id}-${each.key}-an"
    },
  )
}

## Public access block
resource "aws_s3_bucket_public_access_block" "website_distribution_bucket_public_access_block" {
  for_each                = toset(local.deployment_regions)
  provider                = aws.dist
  region                  = each.key
  bucket                  = aws_s3_bucket.website_distribution_bucket[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

## Always enable versioning
resource "aws_s3_bucket_versioning" "website_distribution_bucket_versioning" {
  for_each = toset(local.deployment_regions)
  provider = aws.dist
  region   = each.key
  bucket   = aws_s3_bucket.website_distribution_bucket[each.key].id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Enabled"
  }
}

## Bucket encryption
## bucket_encryption_keys
resource "aws_s3_bucket_server_side_encryption_configuration" "website_distribution_bucket_encryption" {
  for_each = toset(local.deployment_regions)
  provider = aws.dist
  region   = each.key
  bucket   = aws_s3_bucket.website_distribution_bucket[each.key].id
  rule {
    blocked_encryption_types = ["SSE-C"]
    bucket_key_enabled       = true
    apply_server_side_encryption_by_default {
      kms_master_key_id = contains(keys(var.bucket_encryption_keys), each.key) ? var.bucket_encryption_keys[each.key] : null
      sse_algorithm     = contains(keys(var.bucket_encryption_keys), each.key) ? "aws:kms" : "AES256"
    }
  }
}

## Enabled eventbridge notifications
resource "aws_s3_bucket_notification" "website_distribution_bucket_notifications" {
  for_each    = toset(local.deployment_regions)
  provider    = aws.dist
  region      = each.key
  bucket      = aws_s3_bucket.website_distribution_bucket[each.key].id
  eventbridge = true
}

# Cloudfront Bucket Policy
# See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
data "aws_iam_policy_document" "website_distribution_bucket_policy_document" {
  for_each = toset(local.deployment_regions)
  provider = aws.dist
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    # s3:ListBucket applies to the bucket ARN; it lets S3 return 404 (not 403) for missing keys
    resources = [
      aws_s3_bucket.website_distribution_bucket[each.key].arn,
      "${aws_s3_bucket.website_distribution_bucket[each.key].arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cloudfront_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "website_distribution_bucket_policy" {
  for_each = toset(local.deployment_regions)
  provider = aws.dist
  region   = each.key
  bucket   = aws_s3_bucket.website_distribution_bucket[each.key].bucket
  policy   = data.aws_iam_policy_document.website_distribution_bucket_policy_document[each.key].json
}
