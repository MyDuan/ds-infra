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
