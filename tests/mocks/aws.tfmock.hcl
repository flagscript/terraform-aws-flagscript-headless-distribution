# Shared mock data for the AWS provider, loaded by `mock_provider "aws" { source = "./tests/mocks" }`.
#
# Mocked resources and data sources return random values for computed attributes. That's fine
# for most attributes, but some are validated by the provider before the plan completes. Override
# those here with values that are valid but fake.

# IAM policy documents feed `assume_role_policy` and bucket policies, which the provider checks
# are valid JSON policies. A random string fails that check, so return an empty policy.
# The account ID is part of bucket names. Use a realistic 12-digit value so name-length tests
# measure what AWS would actually see.
mock_data "aws_caller_identity" {
  defaults = {
    account_id = "123456789012"
  }
}

mock_data "aws_iam_policy_document" {
  defaults = {
    json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
  }
}
