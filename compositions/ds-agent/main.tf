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

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "aiplatform.googleapis.com",
    "compute.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
    "discoveryengine.googleapis.com"
  ])
  
  project = var.project_id
  service = each.value
  
  disable_on_destroy = false
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
  
  depends_on = [google_project_service.required_apis]
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

# Data Science Agent Setup Module (NEW)
module "data_science_setup" {
  source = "../../modules/data-science-setup"
  
  project_id                   = var.project_id
  location                    = var.location
  dataset_id                  = var.bq_dataset_id
  agent_source_path           = "${path.root}/../../../adk-samples/python/agents/data-science"
  staging_bucket_name         = module.storage.staging_bucket_name
  force_rag_corpus_recreation = var.force_rag_corpus_recreation
  deploy_to_agent_engine      = var.deploy_to_agent_engine
  tags                        = var.tags
  
  depends_on = [
    module.storage,
    module.bigquery,
    module.vertex_ai
  ]
}

# Data sources
data "google_project" "current" {
  project_id = var.project_id
}
