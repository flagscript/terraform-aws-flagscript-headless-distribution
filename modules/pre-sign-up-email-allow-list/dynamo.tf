# ---------------------------------------------------------------------------
# Allow-list table: one item per allowed email, partition key "email" (lowercase).
# ---------------------------------------------------------------------------
resource "aws_dynamodb_table" "allow_list_dynamo_table" {
  region                      = var.user_pool_region
  name                        = "${var.user_pool_name}-email-allow-list"
  billing_mode                = "PAY_PER_REQUEST"
  hash_key                    = "email"
  deletion_protection_enabled = var.table_deletion_protection

  attribute {
    name = "email"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  dynamic "replica" {
    for_each = var.user_pool_replication_region != null ? toset([var.user_pool_replication_region]) : toset([])
    content {
      consistency_mode = "EVENTUAL"
      propagate_tags   = true
      region_name      = replica.key
    }
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(
    {
      "Name" = "${var.user_pool_name}-email-allow-list"
    },
    local.common_tags
  )
}
