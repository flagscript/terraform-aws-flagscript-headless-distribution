<!-- BEGIN_TF_DOCS -->
# Failover example

A headless distribution with a primary origin in `us-east-1` and a warm standby in
`us-west-2`.

- Objects written to the primary bucket are replicated **one way** to the backup bucket,
  including delete markers.
- CloudFront uses an origin group that retries against the backup origin when the primary
  returns `500`, `502`, `503` or `504`.

Deploy your site content to the **primary** bucket only. Objects that existed before
replication was enabled aren't copied; use S3 Batch Replication to backfill them.

```bash
terraform init
terraform apply
```

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.16 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.72 |

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
