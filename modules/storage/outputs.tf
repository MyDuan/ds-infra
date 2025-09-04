output "staging_bucket_name" {
  description = "Name of the staging bucket"
  value       = google_storage_bucket.staging.name
}

output "staging_bucket_url" {
  description = "URL of the staging bucket"
  value       = google_storage_bucket.staging.url
}

output "staging_bucket_self_link" {
  description = "Self link of the staging bucket"
  value       = google_storage_bucket.staging.self_link
}
