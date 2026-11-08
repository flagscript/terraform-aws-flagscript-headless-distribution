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

# route53.tf uses `for_each` over the certificate's domain_validation_options. The real provider
# knows those at plan time, but a mock leaves them unknown until apply, so Terraform can't work
# out the for_each keys. `override_during = plan` makes the mock supply these values during plan.
mock_resource "aws_acm_certificate" {
  override_during = plan
  defaults = {
    arn = "arn:aws:acm:us-east-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
    domain_validation_options = [
      {
        domain_name           = "www.example.com"
        resource_record_name  = "_abc.www.example.com."
        resource_record_type  = "CNAME"
        resource_record_value = "_xyz.acm-validations.aws."
      }
    ]
  }
}
