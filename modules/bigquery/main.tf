# BigQuery dataset for agent data storage
resource "google_bigquery_dataset" "agent_dataset" {
  dataset_id                  = var.dataset_id
  project                     = var.project_id
  location                    = var.dataset_location
  description                 = "Dataset for Data Science Agent - ${var.environment}"
  delete_contents_on_destroy  = false

  # Access control
  access {
    role          = "OWNER"
    user_by_email = var.vertex_ai_sa_email
  }

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

# Sample table for agent analytics (optional)
resource "google_bigquery_table" "agent_logs" {
  dataset_id          = google_bigquery_dataset.agent_dataset.dataset_id
  table_id            = "agent_logs"
  project             = var.project_id
  deletion_protection = var.enable_deletion_protection

  description = "Table for storing agent interaction logs"

  schema = jsonencode([
    {
      name = "timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
      description = "When the interaction occurred"
    },
    {
      name = "session_id"
      type = "STRING"
      mode = "REQUIRED"
      description = "Unique session identifier"
    },
    {
      name = "user_query"
      type = "STRING"
      mode = "NULLABLE"
      description = "User's input query"
    },
    {
      name = "agent_response"
      type = "STRING"
      mode = "NULLABLE"
      description = "Agent's response"
    },
    {
      name = "model_used"
      type = "STRING"
      mode = "NULLABLE"
      description = "Which model was used"
    },
    {
      name = "response_time_ms"
      type = "INTEGER"
      mode = "NULLABLE"
      description = "Response time in milliseconds"
    }
  ])

  # Labels
  labels = merge(
    var.tags,
    {
      environment = var.environment
      table_type  = "logs"
    }
  )
}

# Table for storing agent metrics
resource "google_bigquery_table" "agent_metrics" {
  dataset_id          = google_bigquery_dataset.agent_dataset.dataset_id
  table_id            = "agent_metrics"
  project             = var.project_id
  deletion_protection = var.enable_deletion_protection

  description = "Table for storing agent performance metrics"

  schema = jsonencode([
    {
      name = "date"
      type = "DATE"
      mode = "REQUIRED"
      description = "Date of the metrics"
    },
    {
      name = "total_queries"
      type = "INTEGER"
      mode = "NULLABLE"
      description = "Total number of queries"
    },
    {
      name = "avg_response_time_ms"
      type = "FLOAT"
      mode = "NULLABLE"
      description = "Average response time in milliseconds"
    },
    {
      name = "error_count"
      type = "INTEGER"
      mode = "NULLABLE"
      description = "Number of errors"
    },
    {
      name = "success_rate"
      type = "FLOAT"
      mode = "NULLABLE"
      description = "Success rate as percentage"
    }
  ])

  # Labels
  labels = merge(
    var.tags,
    {
      environment = var.environment
      table_type  = "metrics"
    }
  )
}
