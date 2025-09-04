output "data_store_id" {
  description = "Discovery Engine data store ID"
  value       = google_discovery_engine_data_store.rag_corpus.data_store_id
}

output "search_engine_id" {
  description = "Discovery Engine search engine ID"
  value       = google_discovery_engine_search_engine.rag_search.engine_id
}

output "data_store_name" {
  description = "Discovery Engine data store name"
  value       = google_discovery_engine_data_store.rag_corpus.name
}

output "search_engine_name" {
  description = "Discovery Engine search engine name"
  value       = google_discovery_engine_search_engine.rag_search.name
}
