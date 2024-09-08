<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.60 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.dist"></a> [aws.dist](#provider\_aws.dist) | >= 5.60 |
| <a name="provider_aws.dns"></a> [aws.dns](#provider\_aws.dns) | >= 5.60 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_distribution_bucket"></a> [distribution\_bucket](#module\_distribution\_bucket) | flagscript/flagscript-s3-bucket/aws | 3.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.distribution_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.test_flagscript_net_dvo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_cache_policy.default_cache_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_distribution.cloudfront_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.origin_access_control](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_route53_record.acm_validation_records](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.apex_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_object.test_index](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_route53_zone.site_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | Object that you want CloudFront to return (for example, index.html) when an end user requests the root URL. | `string` | `"index.html"` | no |
| <a name="input_deploy_test_index"></a> [deploy\_test\_index](#input\_deploy\_test\_index) | Whether or not to create a test index.html file. | `bool` | `false` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The domain of the headless website. | `string` | n/a | yes |
| <a name="input_hosted_zone_name"></a> [hosted\_zone\_name](#input\_hosted\_zone\_name) | Name of the hosted zone to hold the route 53 records. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_distribution_arn"></a> [distribution\_arn](#output\_distribution\_arn) | ARN for the distribution. |
| <a name="output_distribution_id"></a> [distribution\_id](#output\_distribution\_id) | Identifier for the distribution. |
<!-- END_TF_DOCS -->