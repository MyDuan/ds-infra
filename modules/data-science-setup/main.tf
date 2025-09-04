# Data Science Agent Setup Module
# This module handles the complete setup of the data science agent including:
# - BigQuery table creation
# - RAG corpus setup
# - Agent wheel building and deployment

# Create BigQuery tables for the data science agent
resource "terraform_data" "create_bq_tables" {
  triggers_replace = [
    var.project_id,
    var.dataset_id,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      cd ${var.agent_source_path}
      source .venv/bin/activate || true
      python3 data_science/utils/create_bq_table.py
    EOT
    environment = {
      GOOGLE_CLOUD_PROJECT = var.project_id
      BQ_DATASET_ID = var.dataset_id
    }
  }
}

# Setup RAG corpus for BQML agent
resource "terraform_data" "setup_rag_corpus" {
  triggers_replace = [
    var.project_id,
    var.location,
    # Trigger when we want to recreate corpus
    var.force_rag_corpus_recreation ? timestamp() : "stable"
  ]

  provisioner "local-exec" {
    command = <<-EOT
      cd ${var.agent_source_path}
      source .venv/bin/activate || true
      
      # Clear existing corpus name to force recreation
      sed -i.bak "s/BQML_RAG_CORPUS_NAME=.*/BQML_RAG_CORPUS_NAME=''/" .env
      
      # Run RAG corpus creation
      python3 data_science/utils/reference_guide_RAG.py
    EOT
    environment = {
      GOOGLE_CLOUD_PROJECT = var.project_id
      GOOGLE_CLOUD_LOCATION = var.location
    }
  }

  depends_on = [terraform_data.create_bq_tables]
}

# Build agent wheel
resource "terraform_data" "build_agent_wheel" {
  triggers_replace = [
    # Rebuild if agent code changes
    filemd5("${var.agent_source_path}/data_science/agent.py"),
    filemd5("${var.agent_source_path}/pyproject.toml"),
  ]

  provisioner "local-exec" {
    command = <<-EOT
      cd ${var.agent_source_path}
      source .venv/bin/activate || true
      uv build --wheel --out-dir deployment
    EOT
  }
}

# Upload wheel file to staging bucket
resource "google_storage_bucket_object" "agent_wheel" {
  name   = "agents/data-science/data_science-0.1.0-py3-none-any.whl"
  bucket = var.staging_bucket_name
  source = "${var.agent_source_path}/deployment/data_science-0.1.0-py3-none-any.whl"

  depends_on = [terraform_data.build_agent_wheel]
}

# Deploy agent to Agent Engine
resource "terraform_data" "deploy_agent_engine" {
  count = var.deploy_to_agent_engine ? 1 : 0
  
  triggers_replace = [
    google_storage_bucket_object.agent_wheel.md5hash,
    # Use the corpus creation trigger instead of file hash to avoid inconsistency
    terraform_data.setup_rag_corpus.id,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      cd ${var.agent_source_path}
      source .venv/bin/activate || true
      cd deployment
      python3 deploy.py --create --project_id=${var.project_id} --location=${var.location} --bucket=${var.staging_bucket_name}
    EOT
    environment = {
      GOOGLE_CLOUD_PROJECT = var.project_id
      GOOGLE_CLOUD_LOCATION = var.location
    }
  }

  depends_on = [
    terraform_data.setup_rag_corpus,
    google_storage_bucket_object.agent_wheel,
  ]
}

# Read the RAG corpus name from the .env file after creation
data "local_file" "agent_env" {
  filename = "${var.agent_source_path}/.env"
  depends_on = [terraform_data.setup_rag_corpus]
}

# Parse corpus name from env file
locals {
  env_content = data.local_file.agent_env.content
  corpus_matches = regex("BQML_RAG_CORPUS_NAME='([^']*)'", local.env_content)
  corpus_name = length(local.corpus_matches) > 0 ? local.corpus_matches[0] : ""
  corpus_id = local.corpus_name != "" ? basename(local.corpus_name) : ""
}
