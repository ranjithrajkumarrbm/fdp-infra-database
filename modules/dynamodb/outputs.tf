output "table_name" {
  description = "Full name of the DynamoDB table."
  value       = aws_dynamodb_table.this.name
}

output "table_id" {
  description = "ID (name) of the DynamoDB table."
  value       = aws_dynamodb_table.this.id
}

output "table_arn" {
  description = "ARN of the DynamoDB table."
  value       = aws_dynamodb_table.this.arn
}

output "stream_arn" {
  description = "ARN of the table's DynamoDB stream, or null when streams are disabled."
  value       = var.stream_enabled ? aws_dynamodb_table.this.stream_arn : null
}

output "stream_label" {
  description = "Timestamp label of the stream, or null when streams are disabled."
  value       = var.stream_enabled ? aws_dynamodb_table.this.stream_label : null
}

output "hash_key" {
  description = "Partition key of the table."
  value       = aws_dynamodb_table.this.hash_key
}

output "range_key" {
  description = "Sort key of the table, or null when there is none."
  value       = aws_dynamodb_table.this.range_key
}

output "global_secondary_index_names" {
  description = "Names of the table's global secondary indexes."
  value       = [for gsi in var.global_secondary_indexes : gsi.name]
}
