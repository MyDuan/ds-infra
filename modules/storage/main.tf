# Cloud Storage bucket for agent staging
resource "google_storage_bucket" "staging" {
  name     = var.staging_bucket_name
  location = var.location
  project  = var.project_id

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = var.enable_deletion_protection
  }

  # Versioning for agent packages
  versioning {
    enabled = var.enable_versioning
  }

  # Lifecycle management
  lifecycle_rule {
    condition {
      age = var.lifecycle_days
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      age                   = 7
      with_state           = "NONCURRENT_TIME"
      num_newer_versions   = 3
    }
    action {
      type = "Delete"
    }
  }

  # CORS for agent deployment
  cors {
    origin          = ["*"]
    method          = ["GET", "POST", "PUT"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  # Labels
  labels = merge(var.labels, var.tags)
}

# Bucket IAM for Vertex AI service accounts
resource "google_storage_bucket_iam_member" "vertex_ai_access" {
  bucket = google_storage_bucket.staging.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-aiplatform.iam.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "compute_engine_access" {
  bucket = google_storage_bucket.staging.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}

# Data source to get current project
data "google_project" "current" {
  project_id = var.project_id
}
