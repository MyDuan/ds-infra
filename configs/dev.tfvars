# Development Environment Configuration
project_id = "YOUR_PROJECT_ID"
location   = "us-central1"
environment = "dev"

# Agent Configuration
agent_display_name = "Data Science Agent - Dev"
agent_description  = "Development instance of the data science agent"

# BigQuery Configuration
bq_dataset_id       = "YOUR_DATASET_ID"
bq_dataset_location = "US"

# Storage Configuration
staging_bucket_name              = "YOUR_PROJECT_ID-ds-agent-staging-dev"
enable_versioning               = true
storage_bucket_lifecycle_days  = 30

# Security Configuration
enable_deletion_protection = false

# Resource Tagging
tags = {
  Environment = "development"
  Team        = "data-science"
  Component   = "ds-agent"
  ManagedBy   = "terraform"
}
