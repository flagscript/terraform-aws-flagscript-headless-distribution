# Tests for input validations in variables.tf (other than bucket_encryption_keys, which has
# its own file).
#
# Run with: terraform init && terraform test
#
# Each rejected case uses `expect_failures` to assert that the plan fails on that specific
# variable's validation, not on something else.

mock_provider "aws" {
  alias  = "dist"
  source = "./tests/mocks"
}

mock_provider "aws" {
  alias  = "dns"
  source = "./tests/mocks"
}

variables {
  distribution_name        = "example-site"
  domain                   = "www.example.com"
  hosted_zone_id           = "Z0123456789EXAMPLE"
  s3_origin_primary_region = "us-east-1"
}

# ---------- domain ----------

# S3 bucket names must be lowercase, and the domain is part of the bucket name.
run "uppercase_domain_is_rejected" {
  command = plan

  variables {
    domain = "WWW.Example.com"
  }

  expect_failures = [var.domain]
}

run "domain_with_invalid_characters_is_rejected" {
  command = plan

  variables {
    domain = "www.example_site.com"
  }

  expect_failures = [var.domain]
}

# 63 characters is the limit, because the normalized domain names the Origin Access Control
# (64-character limit). See the name-length tests in resource_names.tftest.hcl.
run "domain_of_64_characters_is_rejected" {
  command = plan

  variables {
    domain = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.com"
  }

  expect_failures = [var.domain]
}

run "domain_of_63_characters_is_accepted" {
  command = plan

  variables {
    domain = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.com"
  }
}

# ---------- distribution_name ----------

# The distribution name is part of the bucket names, which must be lowercase.
run "uppercase_distribution_name_is_rejected" {
  command = plan

  variables {
    distribution_name = "Example-Site"
  }

  expect_failures = [var.distribution_name]
}

# Bucket names can't start with a hyphen.
run "distribution_name_starting_with_hyphen_is_rejected" {
  command = plan

  variables {
    distribution_name = "-example"
  }

  expect_failures = [var.distribution_name]
}

run "distribution_name_with_dots_is_rejected" {
  command = plan

  variables {
    distribution_name = "example.site"
  }

  expect_failures = [var.distribution_name]
}

# 19 characters is the limit (see the name-length tests in resource_names.tftest.hcl).
run "distribution_name_of_20_characters_is_rejected" {
  command = plan

  variables {
    distribution_name = "abcdefghijklmnopqrst"
  }

  expect_failures = [var.distribution_name]
}

run "distribution_name_of_19_characters_is_accepted" {
  command = plan

  variables {
    distribution_name = "abcdefghijklmnopqrs"
  }
}

# ---------- s3_origin_backup_region ----------

run "backup_region_same_as_primary_is_rejected" {
  command = plan

  variables {
    s3_origin_backup_region = "us-east-1"
  }

  expect_failures = [var.s3_origin_backup_region]
}

# ---------- failover_status_codes ----------

run "unsupported_status_code_is_rejected" {
  command = plan

  variables {
    s3_origin_backup_region = "us-west-2"
    failover_status_codes   = [500, 418]
  }

  expect_failures = [var.failover_status_codes]
}

run "empty_status_codes_are_rejected" {
  command = plan

  variables {
    s3_origin_backup_region = "us-west-2"
    failover_status_codes   = []
  }

  expect_failures = [var.failover_status_codes]
}

# nullable = false makes an explicit null fall back to the default instead of erroring.
run "null_status_codes_fall_back_to_default" {
  command = plan

  variables {
    s3_origin_backup_region = "us-west-2"
    failover_status_codes   = null
  }

  assert {
    condition     = var.failover_status_codes == tolist([500, 502, 503, 504])
    error_message = "Expected null failover_status_codes to fall back to the default."
  }
}

run "client_error_status_codes_are_accepted" {
  command = plan

  variables {
    s3_origin_backup_region = "us-west-2"
    failover_status_codes   = [403, 404, 500, 502, 503, 504]
  }
}

# ---------- origin_connection_attempts / origin_connection_timeout ----------

run "connection_attempts_above_3_are_rejected" {
  command = plan

  variables {
    origin_connection_attempts = 4
  }

  expect_failures = [var.origin_connection_attempts]
}

run "fractional_connection_attempts_are_rejected" {
  command = plan

  variables {
    origin_connection_attempts = 1.5
  }

  expect_failures = [var.origin_connection_attempts]
}

run "connection_timeout_below_1_is_rejected" {
  command = plan

  variables {
    origin_connection_timeout = 0
  }

  expect_failures = [var.origin_connection_timeout]
}

run "fractional_connection_timeout_is_rejected" {
  command = plan

  variables {
    origin_connection_timeout = 2.5
  }

  expect_failures = [var.origin_connection_timeout]
}

run "connection_values_at_upper_limits_are_accepted" {
  command = plan

  variables {
    origin_connection_attempts = 3
    origin_connection_timeout  = 10
  }
}
