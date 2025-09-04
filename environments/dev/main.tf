# Development Environment
# This file links to the main composition

terraform {
  required_version = ">= 1.0"
  
  # Uncomment and configure backend for remote state storage
  # backend "gcs" {
  #   bucket = "YOUR_TERRAFORM_STATE_BUCKET"
  #   prefix = "terraform/ds-agent/dev"
  # }
}

module "ds_agent" {
  source = "../../compositions/ds-agent"
  
  # Load configuration from tfvars file
  # You should create terraform.tfvars in this directory
  # Or pass variables via CLI: terraform apply -var-file="../../configs/dev.tfvars"
}

# Output important values
output "project_id" {
  description = "The GCP project ID"
  value       = module.ds_agent.project_id
}

output "staging_bucket_name" {
  description = "Name of the staging bucket"
  value       = module.ds_agent.staging_bucket_name
}

output "vertex_ai_agent_id" {
  description = "ID of the Vertex AI agent"
  value       = module.ds_agent.vertex_ai_agent_id
}

output "bigquery_dataset_id" {
  description = "BigQuery dataset ID"
  value       = module.ds_agent.bigquery_dataset_id
}
