output "table_names" {
  description = "Map of short table key => full table name."
  value       = { for k, m in module.dynamodb : k => m.table_name }
}

output "table_arns" {
  description = "Map of short table key => table ARN."
  value       = { for k, m in module.dynamodb : k => m.table_arn }
}

output "table_ids" {
  description = "Map of short table key => table ID."
  value       = { for k, m in module.dynamodb : k => m.table_id }
}

output "table_stream_arns" {
  description = "Map of short table key => stream ARN (null when streams are disabled)."
  value       = { for k, m in module.dynamodb : k => m.stream_arn }
}

output "resource_prefix" {
  description = "Prefix applied to all resource names."
  value       = local.prefix
}
