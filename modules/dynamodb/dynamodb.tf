locals {
  table_full_name = "${var.prefix}-${var.table_name}"
}

resource "aws_dynamodb_table" "this" {
  name         = local.table_full_name
  billing_mode = "PAY_PER_REQUEST" # on-demand only
  hash_key     = var.hash_key
  range_key    = var.range_key

  table_class                 = var.table_class
  deletion_protection_enabled = var.deletion_protection_enabled

  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = { for gsi in var.global_secondary_indexes : gsi.name => gsi }
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = global_secondary_index.value.range_key
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.projection_type == "INCLUDE" ? global_secondary_index.value.non_key_attributes : null
    }
  }

  dynamic "local_secondary_index" {
    for_each = { for lsi in var.local_secondary_indexes : lsi.name => lsi }
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = local_secondary_index.value.projection_type == "INCLUDE" ? local_secondary_index.value.non_key_attributes : null
    }
  }

  dynamic "ttl" {
    for_each = var.ttl_attribute_name != "" ? [1] : []
    content {
      enabled        = true
      attribute_name = var.ttl_attribute_name
    }
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  server_side_encryption {
    enabled     = var.server_side_encryption_enabled
    kms_key_arn = var.server_side_encryption_enabled ? var.kms_key_arn : null
  }

  tags = merge(var.tags, { Name = local.table_full_name })
}
