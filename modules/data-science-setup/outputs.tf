output "corpus_name" {
  description = "The full RAG corpus name"
  value       = local.corpus_name
}

output "corpus_id" {
  description = "The RAG corpus ID"
  value       = local.corpus_id
}

output "agent_wheel_path" {
  description = "Path to the uploaded agent wheel file"
  value       = google_storage_bucket_object.agent_wheel.self_link
}

output "agent_wheel_md5" {
  description = "MD5 hash of the agent wheel file"
  value       = google_storage_bucket_object.agent_wheel.md5hash
}
