output "service_account_email" {
  description = "Service account email for Agent Engine operations"
  value       = google_service_account.agent_engine_sa.email
}

output "service_account_id" {
  description = "Service account ID for Agent Engine operations"
  value       = google_service_account.agent_engine_sa.account_id
}

output "project_number" {
  description = "Project number for reference"
  value       = data.google_project.current.number
}
