# Data source to get current project
data "google_project" "current" {
  project_id = var.project_id
}

# Vertex AI service account roles - only create if services are enabled
locals {
  # Only include service accounts that might exist after APIs are enabled
  potential_vertex_ai_accounts = [
    "service-${var.project_number}@gcp-sa-vertex-rag.iam.gserviceaccount.com"
  ]

  vertex_ai_roles = [
    "roles/aiplatform.user",
    "roles/bigquery.user",
    "roles/bigquery.dataViewer", 
    "roles/storage.objectAdmin"
  ]

  # Create combinations for service accounts that might exist
  sa_role_combinations = flatten([
    for sa in local.potential_vertex_ai_accounts : [
      for role in local.vertex_ai_roles : {
        service_account = sa
        role           = role
      }
    ]
  ])
}

# Grant roles to Vertex AI service accounts (will be created by API enablement)
resource "google_project_iam_member" "vertex_ai_permissions" {
  for_each = {
    for combo in local.sa_role_combinations :
    "${combo.service_account}-${combo.role}" => combo
  }

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.service_account}"
  
  # Add a small delay to ensure service accounts are created
  depends_on = [data.google_project.current]
}
