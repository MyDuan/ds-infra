# Import existing BigQuery dataset or create if it doesn't exist
resource "google_bigquery_dataset" "agent_dataset" {
  dataset_id                  = var.dataset_id
  project                     = var.project_id
  location                    = var.dataset_location
  description                 = "Dataset for Data Science Agent - ${var.environment}"
  delete_contents_on_destroy  = false

  # Use lifecycle to prevent destruction if it exists
  lifecycle {
    ignore_changes = [
      # Ignore changes to description and labels if dataset already exists
      description
    ]
  }

  # Access control - simplified to avoid non-existent service accounts
  access {
    role         = "READER"
    special_group = "projectReaders"
  }

  access {
    role         = "WRITER"
    special_group = "projectWriters"
  }

  access {
    role         = "OWNER"
    special_group = "projectOwners"
  }

  # Labels
  labels = merge(
    var.tags,
    {
      environment = var.environment
      module      = "bigquery"
    }
  )
}
