# Note: This configuration creates infrastructure for supporting Agent Engine
# The actual agent deployment is handled by the data-science-setup module

# Service account for Agent Engine operations
resource "google_service_account" "agent_engine_sa" {
  account_id   = "ds-agent-engine-${var.environment}"
  display_name = "Data Science Agent Engine Service Account - ${var.environment}"
  description  = "Service account for Data Science Agent Engine operations"
  project      = var.project_id
}

# IAM binding for BigQuery access
resource "google_project_iam_member" "agent_bigquery_user" {
  project = var.project_id
  role    = "roles/bigquery.user"
  member  = "serviceAccount:${google_service_account.agent_engine_sa.email}"
}

resource "google_project_iam_member" "agent_bigquery_data_viewer" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${google_service_account.agent_engine_sa.email}"
}

# IAM binding for Vertex AI access
resource "google_project_iam_member" "agent_vertex_ai_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.agent_engine_sa.email}"
}

# IAM binding for the service account to access staging bucket
resource "google_storage_bucket_iam_member" "agent_bucket_access" {
  bucket = var.staging_bucket_name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.agent_engine_sa.email}"
}

# Additional IAM binding for default Vertex AI service account
resource "google_storage_bucket_iam_member" "vertex_ai_bucket_access" {
  bucket = var.staging_bucket_name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-aiplatform.iam.gserviceaccount.com"
}

# Data source to get current project
data "google_project" "current" {
  project_id = var.project_id
}
