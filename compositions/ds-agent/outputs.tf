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
output "vertex_ai_service_account_email" {
  description = "Email of the Vertex AI service account"
  value       = module.iam.vertex_ai_service_account_email
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
output "vertex_ai_agent_id" {
  description = "Vertex AI agent (reasoning engine) ID"
  value       = module.vertex_ai.agent_id
}

output "vertex_ai_agent_name" {
  description = "Vertex AI agent (reasoning engine) name"
  value       = module.vertex_ai.agent_name
}

output "vertex_ai_agent_endpoint" {
  description = "Vertex AI agent endpoint URL"
  value       = module.vertex_ai.agent_endpoint
}

# RAG Outputs (Optional)
output "rag_corpus_id" {
  description = "RAG corpus ID"
  value       = var.rag_corpus_id != null ? module.rag[0].corpus_id : null
}

output "rag_corpus_name" {
  description = "RAG corpus name"
  value       = var.rag_corpus_id != null ? module.rag[0].corpus_name : null
}
