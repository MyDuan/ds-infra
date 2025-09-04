# Cloud Storage bucket for agent staging
resource "google_storage_bucket" "staging" {
  name     = var.staging_bucket_name
  location = var.location
  project  = var.project_id

  # Enable uniform bucket-level access to comply with org policy
  uniform_bucket_level_access = true

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
      with_state           = "ARCHIVED"
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

# Data source to get current project
data "google_project" "current" {
  project_id = var.project_id
}
