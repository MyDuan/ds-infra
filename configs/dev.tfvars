# Development Environment Configuration for Data Science Agent
# This file contains actual values for the development environment
# DO NOT commit this file to version control

# Required: Your GCP Project Configuration
project_id = "xxx"
location   = "us-east4"  # Use the same location as your agent registration tool
environment = "dev"

# Agent Configuration
agent_display_name = "Data Science Agent - Dev"
agent_description  = "Development instance of the multi-agent data science system for BigQuery analysis, BQML model training, and data visualization"

# BigQuery Configuration
bq_dataset_id       = "forecasting_sticker_sales"  # Based on your .env file
bq_dataset_location = "US"

# Storage Configuration
staging_bucket_name              = "xxx-ds-agent-staging-dev"
enable_versioning               = true
storage_bucket_lifecycle_days  = 30

# Security Configuration  
enable_deletion_protection = false  # Set to true for production

# Vertex AI Models Configuration
vertex_ai_models = [
  "gemini-2.5-flash"
]

# RAG Configuration (optional - will be auto-generated during agent setup)
# Leave this null initially, it will be populated after running the RAG setup
rag_corpus_id = null  # Will be set after running python3 data_science/utils/reference_guide_RAG.py

# Resource Tagging (GCS labels must be lowercase and can only contain letters, numbers, hyphens, and underscores)
tags = {
  environment = "development"
  team        = "data-science"
  component   = "ds-agent"
  managed_by  = "terraform"
  owner       = "xxx"
}