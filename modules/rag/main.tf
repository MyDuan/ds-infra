# Vertex AI Search (formerly Discovery Engine) for RAG
resource "google_discovery_engine_data_store" "rag_corpus" {
  location         = var.location
  data_store_id    = var.corpus_id
  display_name     = "RAG Corpus - ${var.environment}"
  project          = var.project_id
  content_config   = "CONTENT_REQUIRED"
  solution_types   = ["SOLUTION_TYPE_SEARCH"]
  industry_vertical = "GENERIC"

  create_time = timestamp()
}

# Search engine for the data store
resource "google_discovery_engine_search_engine" "rag_search" {
  engine_id    = "${var.corpus_id}-search"
  collection_id = "default_collection"
  location     = var.location
  project      = var.project_id
  display_name = "RAG Search Engine - ${var.environment}"

  search_engine_config {
    search_tier = "SEARCH_TIER_STANDARD"
    search_add_ons = ["SEARCH_ADD_ON_LLM"]
  }

  data_store_ids = [google_discovery_engine_data_store.rag_corpus.data_store_id]

  depends_on = [google_discovery_engine_data_store.rag_corpus]
}

# IAM binding for Vertex AI to access the search engine
resource "google_project_iam_member" "vertex_ai_search_access" {
  project = var.project_id
  role    = "roles/discoveryengine.viewer"
  member  = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-aiplatform.iam.gserviceaccount.com"
}

# Data source to get current project
data "google_project" "current" {
  project_id = var.project_id
}
