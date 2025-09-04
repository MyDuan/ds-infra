output "dataset_id" {
  description = "BigQuery dataset ID"
  value       = google_bigquery_dataset.agent_dataset.dataset_id
}

output "dataset_location" {
  description = "BigQuery dataset location"
  value       = google_bigquery_dataset.agent_dataset.location
}

output "dataset_self_link" {
  description = "BigQuery dataset self link"
  value       = google_bigquery_dataset.agent_dataset.self_link
}

output "agent_logs_table_id" {
  description = "Agent logs table ID"
  value       = google_bigquery_table.agent_logs.table_id
}

output "agent_metrics_table_id" {
  description = "Agent metrics table ID"
  value       = google_bigquery_table.agent_metrics.table_id
}
