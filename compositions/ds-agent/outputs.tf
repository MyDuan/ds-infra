# Composition Outputs
# These outputs expose the key resources created by the composition

# Project Information
output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "location" {
  description = "The GCP region/location"
  value       = var.location
}

output "environment" {
  description = "The environment name"
  value       = var.environment
}

# Storage Outputs
output "staging_bucket_name" {
  description = "Name of the staging bucket"
  value       = module.storage.staging_bucket_name
}

output "staging_bucket_url" {
  description = "URL of the staging bucket"
  value       = module.storage.staging_bucket_url
}

# IAM Outputs
output "iam_vertex_ai_service_account_email" {
  description = "Email of the primary Vertex AI service account from IAM module"
  value       = module.iam.primary_vertex_ai_service_account
}

# BigQuery Outputs
output "bigquery_dataset_id" {
  description = "BigQuery dataset ID"
  value       = module.bigquery.dataset_id
}

output "bigquery_dataset_location" {
  description = "BigQuery dataset location"
  value       = module.bigquery.dataset_location
}

# Vertex AI Outputs
output "vertex_ai_service_account_email" {
  description = "Service account email for Agent Engine operations"
  value       = module.vertex_ai.service_account_email
}

output "project_number" {
  description = "Project number for Vertex AI operations"
  value       = module.vertex_ai.project_number
}

# Data Science Setup Outputs
output "ds_rag_corpus_name" {
  description = "Full RAG corpus name from data science setup"
  value       = module.data_science_setup.corpus_name
}

output "ds_rag_corpus_id" {
  description = "RAG corpus ID from data science setup"
  value       = module.data_science_setup.corpus_id
}

output "agent_wheel_path" {
  description = "Path to the uploaded agent wheel file"
  value       = module.data_science_setup.agent_wheel_path
}

# RAG Outputs (Optional - from RAG module if configured)
output "rag_corpus_id" {
  description = "RAG corpus ID from external RAG module (if configured)"
  value       = var.rag_corpus_id != null ? module.rag[0].corpus_id : null
}

output "rag_corpus_name" {
  description = "RAG corpus name from external RAG module (if configured)"
  value       = var.rag_corpus_id != null ? module.rag[0].corpus_name : null
}
