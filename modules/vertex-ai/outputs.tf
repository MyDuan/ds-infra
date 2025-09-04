output "agent_id" {
  description = "Vertex AI agent ID"
  value       = google_vertex_ai_agent.ds_agent.agent_id
}

output "agent_name" {
  description = "Vertex AI agent name"
  value       = google_vertex_ai_agent.ds_agent.name
}

output "agent_display_name" {
  description = "Vertex AI agent display name"
  value       = google_vertex_ai_agent.ds_agent.display_name
}

output "endpoint_id" {
  description = "Vertex AI endpoint ID"
  value       = google_vertex_ai_endpoint.agent_endpoint.id
}

output "endpoint_name" {
  description = "Vertex AI endpoint name"
  value       = google_vertex_ai_endpoint.agent_endpoint.name
}
