output "vertex_ai_service_accounts" {
  description = "List of Vertex AI service accounts"
  value       = local.potential_vertex_ai_accounts
}

output "primary_vertex_ai_service_account" {
  description = "Primary Vertex AI service account"
  value       = "service-${var.project_number}@gcp-sa-aiplatform.iam.gserviceaccount.com"
}

output "compute_engine_service_account" {
  description = "Compute Engine default service account"
  value       = "${var.project_number}-compute@developer.gserviceaccount.com"
}
