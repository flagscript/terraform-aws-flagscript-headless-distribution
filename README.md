<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.60 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.60 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_distribution_bucket"></a> [distribution\_bucket](#module\_distribution\_bucket) | flagscript/flagscript-s3-bucket/aws | 3.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.distribution_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_cloudfront_cache_policy.default_cache_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_distribution.cloudfront_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.origin_access_control](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | Object that you want CloudFront to return (for example, index.html) when an end user requests the root URL. | `string` | `"index.html"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The domain of the headless website. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->