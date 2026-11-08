# Tests for generated resource names and the single-region vs failover wiring.
#
# Run with: terraform init && terraform test
#
# The mock account ID in tests/mocks is a realistic 12 digits, so these length checks match
# what AWS would see.

mock_provider "aws" {
  alias  = "dist"
  source = "./tests/mocks"
}

mock_provider "aws" {
  alias  = "dns"
  source = "./tests/mocks"
}

variables {
  # The longest domain the validation allows (32 characters).
  domain                   = "abcdefghijklmnopqrstuvwxyz12.com"
  hosted_zone_id           = "Z0123456789EXAMPLE"
  s3_origin_primary_region = "us-east-1"
}

# S3 bucket names max out at 63 characters. Use one of the longest region names to check the
# worst case.
run "longest_bucket_name_fits_s3_limit" {
  command = plan

  variables {
    s3_origin_primary_region = "ap-southeast-4"
  }

  assert {
    condition     = length(output.distribution_bucket_name["ap-southeast-4"]) <= 63
    error_message = "Bucket name is over 63 characters: ${output.distribution_bucket_name["ap-southeast-4"]}"
  }
}

# IAM role names max out at 64 characters.
run "longest_replication_role_name_fits_iam_limit" {
  command = plan

  variables {
    s3_origin_backup_region = "us-west-2"
  }

  assert {
    condition     = length(aws_iam_role.distribution_replication_role[0].name) <= 64
    error_message = "Replication role name is over 64 characters: ${aws_iam_role.distribution_replication_role[0].name}"
  }
}

# Origin groups need exactly two members, so a single-region distribution must target the
# primary origin directly and create no replication resources.
run "single_region_targets_primary_origin" {
  command = plan

  assert {
    condition     = length(aws_cloudfront_distribution.cloudfront_distribution.origin_group) == 0
    error_message = "Expected no origin group without a backup region."
  }

  assert {
    condition     = aws_cloudfront_distribution.cloudfront_distribution.default_cache_behavior[0].target_origin_id == "primary"
    error_message = "Expected the default cache behavior to target the primary origin."
  }

  assert {
    condition     = length(aws_s3_bucket_replication_configuration.distribution_replication_primary_to_secondary) == 0
    error_message = "Expected no replication configuration without a backup region."
  }
}

run "failover_targets_origin_group" {
  command = plan

  variables {
    s3_origin_backup_region = "us-west-2"
  }

  assert {
    condition     = length(aws_cloudfront_distribution.cloudfront_distribution.origin_group) == 1
    error_message = "Expected one origin group with a backup region."
  }

  assert {
    condition     = aws_cloudfront_distribution.cloudfront_distribution.default_cache_behavior[0].target_origin_id == "s3-failover"
    error_message = "Expected the default cache behavior to target the failover origin group."
  }

  assert {
    condition     = toset(keys(output.distribution_bucket_name)) == toset(["us-east-1", "us-west-2"])
    error_message = "Expected bucket outputs keyed by both regions."
  }
}
