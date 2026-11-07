<!-- BEGIN_TF_DOCS -->
# KMS failover example

A failover distribution (primary `us-east-1`, backup `us-west-2`) where each origin
bucket is encrypted with a customer-managed KMS key in its own region.

Passing `bucket_encryption_keys` makes the module:

- set SSE-KMS (with an S3 bucket key) as the default encryption on each bucket
- opt the replication rule in to SSE-KMS objects and re-encrypt replicas with the
  backup-region key
- grant the replication role `kms:Decrypt` on the primary key and `kms:Encrypt` /
  `kms:GenerateDataKey` on the backup key, scoped to S3 and these buckets

CloudFront reads the objects through Origin Access Control, so each key policy must also
allow the `cloudfront.amazonaws.com` service principal to `kms:Decrypt` for this
distribution. This example's key policies grant that.

```bash
terraform init
terraform apply
```

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.16 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.72 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws.dist"></a> [aws.dist](#provider\_aws.dist) | >= 6.72 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_headless_distribution"></a> [headless\_distribution](#module\_headless\_distribution) | flagscript/flagscript-headless-distribution/aws | ~> 1.3 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_kms_key.origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_distribution_arn"></a> [distribution\_arn](#output\_distribution\_arn) | ARN of the CloudFront distribution. |
| <a name="output_distribution_id"></a> [distribution\_id](#output\_distribution\_id) | ID of the CloudFront distribution. |
<!-- END_TF_DOCS -->
