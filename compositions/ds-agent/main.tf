# Data Science Agent Composition
# This is the main composition that combines all modules

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.location
}

# Storage Module
module "storage" {
  source = "../../modules/storage"
  
  project_id                    = var.project_id
  location                     = var.location
  environment                  = var.environment
  staging_bucket_name          = var.staging_bucket_name
  enable_versioning           = var.enable_versioning
  lifecycle_days              = var.storage_bucket_lifecycle_days
  enable_deletion_protection  = var.enable_deletion_protection
  tags                        = var.tags
}

# IAM Module
module "iam" {
  source = "../../modules/iam"
  
  project_id    = var.project_id
  project_number = data.google_project.current.number
  environment   = var.environment
  tags          = var.tags
}

# BigQuery Module
module "bigquery" {
  source = "../../modules/bigquery"
  
  project_id          = var.project_id
  dataset_id          = var.bq_dataset_id
  dataset_location    = var.bq_dataset_location
  environment         = var.environment
  vertex_ai_sa_email  = module.iam.primary_vertex_ai_service_account
  tags                = var.tags
}

# RAG Module (Optional)
module "rag" {
  source = "../../modules/rag"
  count  = var.rag_corpus_id != null ? 1 : 0
  
  project_id    = var.project_id
  location      = var.location
  corpus_id     = var.rag_corpus_id
  environment   = var.environment
  tags          = var.tags
}

# Vertex AI Module
module "vertex_ai" {
  source = "../../modules/vertex-ai"
  
  project_id              = var.project_id
  location               = var.location
  environment            = var.environment
  agent_display_name     = var.agent_display_name
  agent_description      = var.agent_description
  staging_bucket_name    = module.storage.staging_bucket_name
  bigquery_dataset_id    = var.bq_dataset_id
  vertex_ai_models       = var.vertex_ai_models
  rag_corpus_id          = var.rag_corpus_id
  tags                   = var.tags
  
  depends_on = [
    module.storage,
    module.iam,
    module.bigquery
  ]
}

# Data sources
data "google_project" "current" {
  project_id = var.project_id
}
