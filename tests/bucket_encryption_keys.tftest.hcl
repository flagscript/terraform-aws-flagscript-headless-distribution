# Tests for the bucket_encryption_keys validation in variables.tf.
#
# Run with: terraform init && terraform test
#
# These use mock providers, so they plan against fake AWS responses and need no credentials.
# Input validations only run during plan, not `terraform validate`, which is why these tests
# use `command = plan`.

# The module requires two aliased providers. Both share the mock data in tests/mocks.
mock_provider "aws" {
  alias  = "dist"
  source = "./tests/mocks"
}

mock_provider "aws" {
  alias  = "dns"
  source = "./tests/mocks"
}

# Defaults for every run below; each run can override these.
variables {
  distribution_name        = "example-site"
  domain                   = "www.example.com"
  hosted_zone_id           = "Z0123456789EXAMPLE"
  s3_origin_primary_region = "us-east-1"
  s3_origin_backup_region  = "us-west-2"
}

# A primary-region key without a backup-region key would enable SSE-KMS replication with no
# replica key, which S3 rejects at apply time.
run "primary_key_only_is_rejected" {
  command = plan

  variables {
    bucket_encryption_keys = {
      "us-east-1" = "arn:aws:kms:us-east-1:111111111111:key/primary"
    }
  }

  expect_failures = [var.bucket_encryption_keys]
}

# A backup-region key without a primary-region key would silently go unused for replicas.
run "backup_key_only_is_rejected" {
  command = plan

  variables {
    bucket_encryption_keys = {
      "us-west-2" = "arn:aws:kms:us-west-2:111111111111:key/backup"
    }
  }

  expect_failures = [var.bucket_encryption_keys]
}

run "keys_for_both_regions_are_accepted" {
  command = plan

  variables {
    bucket_encryption_keys = {
      "us-east-1" = "arn:aws:kms:us-east-1:111111111111:key/primary"
      "us-west-2" = "arn:aws:kms:us-west-2:111111111111:key/backup"
    }
  }
}

run "no_keys_are_accepted" {
  command = plan
}

# Without a backup region there's no replication, so a single key is fine.
run "single_region_with_key_is_accepted" {
  command = plan

  variables {
    s3_origin_backup_region = null
    bucket_encryption_keys = {
      "us-east-1" = "arn:aws:kms:us-east-1:111111111111:key/primary"
    }
  }
}
