<!-- BEGIN_TF_DOCS -->
# Basic example

A single-region headless distribution: one private S3 origin in `us-east-1`, served
through CloudFront with an ACM certificate for `www.example.com`.

Both provider aliases point at the same account here. Point `aws.dns` at a different
account if your Route 53 hosted zone lives elsewhere.

```bash
terraform init
terraform apply
```

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_headless_distribution"></a> [headless\_distribution](#module\_headless\_distribution) | flagscript/flagscript-headless-distribution/aws | ~> 1.3 |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_distribution_arn"></a> [distribution\_arn](#output\_distribution\_arn) | ARN of the CloudFront distribution. |
| <a name="output_distribution_id"></a> [distribution\_id](#output\_distribution\_id) | ID of the CloudFront distribution. |
<!-- END_TF_DOCS -->
