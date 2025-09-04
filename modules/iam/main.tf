# Data source to get current project
data "google_project" "current" {
  project_id = var.project_id
}

# Vertex AI service account roles
locals {
  vertex_ai_service_accounts = [
    "service-${var.project_number}@gcp-sa-aiplatform.iam.gserviceaccount.com",
    "service-${var.project_number}@gcp-sa-aiplatform-re.iam.gserviceaccount.com",
    "service-${var.project_number}@gcp-sa-vertex-rag.iam.gserviceaccount.com"
  ]

  vertex_ai_roles = [
    "roles/aiplatform.user",
    "roles/bigquery.user",
    "roles/bigquery.dataViewer",
    "roles/storage.objectAdmin"
  ]

  # Create a cartesian product of service accounts and roles
  sa_role_combinations = flatten([
    for sa in local.vertex_ai_service_accounts : [
      for role in local.vertex_ai_roles : {
        service_account = sa
        role           = role
      }
    ]
  ])
}

# Grant roles to Vertex AI service accounts
resource "google_project_iam_member" "vertex_ai_permissions" {
  for_each = {
    for combo in local.sa_role_combinations :
    "${combo.service_account}-${combo.role}" => combo
  }

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.service_account}"
}

# Grant roles to Compute Engine default service account
resource "google_project_iam_member" "compute_engine_permissions" {
  for_each = toset([
    "roles/aiplatform.user",
    "roles/storage.objectAdmin"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
}

# Additional IAM binding for Discovery Engine (if needed)
resource "google_project_iam_member" "discovery_engine_permissions" {
  project = var.project_id
  role    = "roles/discoveryengine.serviceAgent"
  member  = "serviceAccount:service-${var.project_number}@gcp-sa-discoveryengine.iam.gserviceaccount.com"
}
