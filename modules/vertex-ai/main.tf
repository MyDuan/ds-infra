# Vertex AI Agent
resource "google_vertex_ai_agent" "ds_agent" {
  project      = var.project_id
  location     = var.location
  agent_id     = "ds-agent-${var.environment}"
  display_name = var.agent_display_name
  description  = var.agent_description

  # Agent configuration
  agent_config {
    # Use the specified model or default to Gemini Pro
    model = length(var.vertex_ai_models) > 0 ? var.vertex_ai_models[0] : "projects/${var.project_id}/locations/${var.location}/publishers/google/models/gemini-1.5-pro"
    
    # System instruction for the agent
    system_instruction = "You are a helpful data science assistant. You can help with data analysis, machine learning, and statistical questions. You have access to BigQuery data and can perform various analytical tasks."
    
    # Temperature for response generation
    temperature = 0.1
    
    # Maximum number of tokens in response
    max_tokens = 2048
  }

  # Tools configuration
  dynamic "tools" {
    for_each = var.bigquery_dataset_id != null ? [1] : []
    content {
      # BigQuery tool
      bigquery_tool {
        dataset_ids = [var.bigquery_dataset_id]
      }
    }
  }

  # RAG configuration (if corpus is provided)
  dynamic "tools" {
    for_each = var.rag_corpus_id != null ? [1] : []
    content {
      retrieval_tool {
        vertex_ai_search {
          data_store = "projects/${var.project_id}/locations/${var.location}/collections/default_collection/dataStores/${var.rag_corpus_id}"
        }
      }
    }
  }

  # Security settings
  security_settings {
    enable_debugging_features = var.environment != "prod"
  }

  # Labels
  labels = merge(
    var.tags,
    {
      environment = var.environment
      module      = "vertex-ai"
    }
  )
}

# Vertex AI Endpoint for the agent (if needed for custom serving)
resource "google_vertex_ai_endpoint" "agent_endpoint" {
  name         = "ds-agent-endpoint-${var.environment}"
  display_name = "Data Science Agent Endpoint - ${var.environment}"
  description  = "Endpoint for the Data Science Agent"
  location     = var.location
  project      = var.project_id

  labels = merge(
    var.tags,
    {
      environment = var.environment
      module      = "vertex-ai"
    }
  )
}

# IAM binding for the agent to access staging bucket
resource "google_storage_bucket_iam_member" "agent_bucket_access" {
  bucket = var.staging_bucket_name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-aiplatform.iam.gserviceaccount.com"
}

# Data source to get current project
data "google_project" "current" {
  project_id = var.project_id
}
