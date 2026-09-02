###############################################################################
# Root configuration - DynamoDB tables.
#
# Region is fixed. `var.environment` selects one of the local config sets and
# every table is named/tagged from a computed prefix:
#
#   prefix = "<app_name>-<env_name>-<region_short_name>"   e.g. fdp-dev-euw2
#
# Each entry in `local.env.tables` becomes one call of ./modules/dynamodb and
# one table named "<prefix>-<key>".
###############################################################################

variable "environment" {
  description = "Which local config set to deploy. One of: dev, prod."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be either \"dev\" or \"prod\"."
  }
}

locals {
  # ---- Fixed identity ---------------------------------------------------- #
  app_name = "fdp"
  region   = "eu-west-2" # London

  region_short_names = {
    "eu-west-2" = "euw2"
    "eu-west-1" = "euw1"
    "us-east-1" = "use1"
  }
  region_short = local.region_short_names[local.region]

  # ---- Per-environment config sets (identical keys in both) ------------- #
  #
  # Every table is on-demand (PAY_PER_REQUEST). Add a table by putting the same
  # key under `tables` in BOTH sets; each key becomes a table named
  # "<prefix>-<key>". Terraform manages the table only - never items.
  #
  env_configs = {
    dev = {
      env_name = "dev"

      # Table-wide defaults. Dev favours cost and quick teardown.
      point_in_time_recovery_enabled = false
      deletion_protection_enabled    = false
      server_side_encryption_enabled = false

      tables = {
        transactions = {
          hash_key  = "transactionId"
          range_key = "customerId"
          attributes = [
            { name = "transactionId", type = "S" },
            { name = "customerId", type = "S" },
          ]
          global_secondary_indexes = []
          ttl_attribute_name       = ""
          stream_enabled           = false
          stream_view_type         = null
        }
      }
    }

    prod = {
      env_name = "prod"

      # Prod favours durability: PITR on, deletion protection on, CMK encryption.
      point_in_time_recovery_enabled = true
      deletion_protection_enabled    = true
      server_side_encryption_enabled = true

      tables = {
        transactions = {
          hash_key  = "transactionId"
          range_key = "customerId"
          attributes = [
            { name = "transactionId", type = "S" },
            { name = "customerId", type = "S" },
          ]
          global_secondary_indexes = []
          ttl_attribute_name       = ""
          stream_enabled           = false
          stream_view_type         = null
        }
      }
    }
  }

  env    = local.env_configs[var.environment]
  prefix = "${local.app_name}-${local.env.env_name}-${local.region_short}"

  common_tags = {
    Application = local.app_name
    Environment = local.env.env_name
    Region      = local.region
    ManagedBy   = "terraform"
    Repository  = "fdp-infra-database"
  }

  # CMK ARN for encryption at rest in environments that use it. Leave null to
  # fall back to the AWS-managed aws/dynamodb key.
  kms_key_arn = null
}

###############################################################################
# DynamoDB tables
###############################################################################

module "dynamodb" {
  source   = "./modules/dynamodb"
  for_each = local.env.tables

  prefix     = local.prefix
  table_name = each.key

  hash_key   = each.value.hash_key
  range_key  = each.value.range_key
  attributes = each.value.attributes

  global_secondary_indexes = each.value.global_secondary_indexes
  ttl_attribute_name       = each.value.ttl_attribute_name

  stream_enabled   = each.value.stream_enabled
  stream_view_type = each.value.stream_view_type

  point_in_time_recovery_enabled = local.env.point_in_time_recovery_enabled
  deletion_protection_enabled    = local.env.deletion_protection_enabled
  server_side_encryption_enabled = local.env.server_side_encryption_enabled
  kms_key_arn                    = local.kms_key_arn

  tags = local.common_tags
}
