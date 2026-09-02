variable "prefix" {
  description = "Prefix applied to the name of every resource, e.g. \"fdp-dev-euw2\"."
  type        = string
}

variable "table_name" {
  description = "Short table name. The created table is named \"<prefix>-<table_name>\"."
  type        = string
}

variable "hash_key" {
  description = "Name of the partition key. Must appear in var.attributes."
  type        = string
}

variable "range_key" {
  description = "Name of the sort key, or null for none. Must appear in var.attributes when set."
  type        = string
  default     = null
}

variable "attributes" {
  description = "Key/index attribute definitions. Only attributes used by the table or an index belong here."
  type = list(object({
    name = string
    type = string # S | N | B
  }))

  validation {
    condition     = alltrue([for a in var.attributes : contains(["S", "N", "B"], a.type)])
    error_message = "Each attribute type must be one of S, N or B."
  }

  validation {
    condition     = length(distinct([for a in var.attributes : a.name])) == length(var.attributes)
    error_message = "Attribute names must be unique."
  }
}

variable "global_secondary_indexes" {
  description = "Global secondary indexes. Every referenced key must be present in var.attributes."
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = optional(string, "ALL") # ALL | KEYS_ONLY | INCLUDE
    non_key_attributes = optional(list(string), [])
  }))
  default = []

  validation {
    condition     = alltrue([for g in var.global_secondary_indexes : contains(["ALL", "KEYS_ONLY", "INCLUDE"], g.projection_type)])
    error_message = "global_secondary_indexes.projection_type must be one of ALL, KEYS_ONLY or INCLUDE."
  }
}

variable "local_secondary_indexes" {
  description = "Local secondary indexes. Only creatable at table creation time and require a table range_key."
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = optional(string, "ALL") # ALL | KEYS_ONLY | INCLUDE
    non_key_attributes = optional(list(string), [])
  }))
  default = []

  validation {
    condition     = alltrue([for l in var.local_secondary_indexes : contains(["ALL", "KEYS_ONLY", "INCLUDE"], l.projection_type)])
    error_message = "local_secondary_indexes.projection_type must be one of ALL, KEYS_ONLY or INCLUDE."
  }
}

variable "ttl_attribute_name" {
  description = "Item attribute holding the expiry epoch. Empty string disables TTL."
  type        = string
  default     = ""
}

variable "point_in_time_recovery_enabled" {
  description = "Enable continuous backups / point-in-time recovery."
  type        = bool
  default     = true
}

variable "deletion_protection_enabled" {
  description = "Block table deletion until this is turned off."
  type        = bool
  default     = true
}

variable "server_side_encryption_enabled" {
  description = "Use a customer-managed KMS key for encryption at rest. When false the AWS-owned key is used."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "CMK ARN for encryption at rest. Null with server_side_encryption_enabled uses the AWS-managed aws/dynamodb key."
  type        = string
  default     = null
}

variable "stream_enabled" {
  description = "Enable DynamoDB Streams on the table."
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream record content. One of: NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES, KEYS_ONLY. Required when stream_enabled."
  type        = string
  default     = null

  validation {
    condition     = var.stream_view_type == null || contains(["NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES", "KEYS_ONLY"], coalesce(var.stream_view_type, "NEW_IMAGE"))
    error_message = "stream_view_type must be one of NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES or KEYS_ONLY."
  }
}

variable "table_class" {
  description = "Storage class. One of: STANDARD, STANDARD_INFREQUENT_ACCESS."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "table_class must be either STANDARD or STANDARD_INFREQUENT_ACCESS."
  }
}

variable "tags" {
  description = "Tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}
