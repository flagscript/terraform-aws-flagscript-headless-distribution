# IAM role S3 assumes to replicate
data "aws_iam_policy_document" "s3_assume_role_policy_document" {
  provider = aws.dist
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "distribution_replication_role" {
  count              = local.use_s3_failover ? 1 : 0
  provider           = aws.dist
  assume_role_policy = data.aws_iam_policy_document.s3_assume_role_policy_document.json
  description        = "S3 origin replication role for ${var.domain}"
  name               = "${local.title_domain}DistributionReplicationRole"
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.title_domain}DistributionReplicationRole"
    },
  )
}

data "aws_iam_policy_document" "distribution_replication_policy_document" {
  count    = local.use_s3_failover ? 1 : 0
  provider = aws.dist
  # Read replication config / list the source
  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]
    resources = [aws_s3_bucket.website_distribution_bucket[var.s3_origin_primary_region].arn]
  }

  # Read object versions from the source
  statement {
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]
    resources = ["${aws_s3_bucket.website_distribution_bucket[var.s3_origin_primary_region].arn}/*"]
  }

  # Write replicas into the destination
  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]
    resources = ["${aws_s3_bucket.website_distribution_bucket[var.s3_origin_backup_region].arn}/*"]
  }

  # Decrypt source objects
  dynamic "statement" {
    for_each = contains(keys(var.bucket_encryption_keys), var.s3_origin_primary_region) ? [true] : []
    content {
      actions   = ["kms:Decrypt"]
      resources = [var.bucket_encryption_keys[var.s3_origin_primary_region]]
      condition {
        test     = "StringLike"
        variable = "kms:ViaService"
        values   = ["s3.${var.s3_origin_primary_region}.amazonaws.com"]
      }
      condition {
        test     = "StringLike"
        variable = "kms:EncryptionContext:aws:s3:arn"
        values = [
          aws_s3_bucket.website_distribution_bucket[var.s3_origin_primary_region].arn,        # bucket key is enabled
          "${aws_s3_bucket.website_distribution_bucket[var.s3_origin_primary_region].arn}/*", # when it isn't
        ]
      }
    }
  }

  # Encrypt replicas in the destination
  dynamic "statement" {
    for_each = contains(keys(var.bucket_encryption_keys), var.s3_origin_backup_region) ? [true] : []
    content {
      actions   = ["kms:Encrypt", "kms:GenerateDataKey"]
      resources = [var.bucket_encryption_keys[var.s3_origin_backup_region]]
      condition {
        test     = "StringLike"
        variable = "kms:ViaService"
        values   = ["s3.${var.s3_origin_backup_region}.amazonaws.com"]
      }
      condition {
        test     = "StringLike"
        variable = "kms:EncryptionContext:aws:s3:arn"
        values = [
          aws_s3_bucket.website_distribution_bucket[var.s3_origin_backup_region].arn,        # bucket key is enabled
          "${aws_s3_bucket.website_distribution_bucket[var.s3_origin_backup_region].arn}/*", # when it isn't
        ]
      }
    }
  }

}

resource "aws_iam_role_policy" "replication" {
  count    = local.use_s3_failover ? 1 : 0
  provider = aws.dist
  name     = "${local.normalized_domain}-s3-replication"
  role     = aws_iam_role.distribution_replication_role[0].id
  policy   = data.aws_iam_policy_document.distribution_replication_policy_document[0].json
}

# Replication config (only on the primary = one-way)
resource "aws_s3_bucket_replication_configuration" "distribution_replication_primary_to_secondary" {
  depends_on = [ # Versioning and encryption must be enabled before the replication config is applied
    aws_s3_bucket_versioning.website_distribution_bucket_versioning,
    aws_s3_bucket_server_side_encryption_configuration.website_distribution_bucket_encryption
  ]

  count    = local.use_s3_failover ? 1 : 0
  provider = aws.dist
  bucket   = aws_s3_bucket.website_distribution_bucket[var.s3_origin_primary_region].id
  role     = aws_iam_role.distribution_replication_role[0].arn

  rule {
    id     = "replicate-all"
    status = "Enabled"

    delete_marker_replication { status = "Enabled" }

    filter {} # empty filter = whole bucket (use prefix/tag to narrow)

    destination {
      bucket        = aws_s3_bucket.website_distribution_bucket[var.s3_origin_backup_region].arn
      storage_class = "STANDARD" # or STANDARD_IA / GLACIER_IR to save cost on the DR copy

      # key in the destination region used to re-encrypt replicas
      dynamic "encryption_configuration" {
        for_each = contains(keys(var.bucket_encryption_keys), var.s3_origin_backup_region) ? [true] : []
        content {
          replica_kms_key_id = var.bucket_encryption_keys[var.s3_origin_backup_region]
        }
      }
    }

    # opt in to replicating SSE-KMS objects
    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = contains(keys(var.bucket_encryption_keys), var.s3_origin_primary_region) ? "Enabled" : "Disabled"
      }
    }

  }
}
