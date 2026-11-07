# Shared mock data for the AWS provider, loaded by `mock_provider "aws" { source = "./tests/mocks" }`.
#
# Mocked resources and data sources return random values for computed attributes. That's fine
# for most attributes, but some are validated by the provider before the plan completes. Override
# those here with values that are valid but fake.

# IAM policy documents feed `assume_role_policy` and bucket policies, which the provider checks
# are valid JSON policies. A random string fails that check, so return an empty policy.
mock_data "aws_iam_policy_document" {
  defaults = {
    json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
  }
}
