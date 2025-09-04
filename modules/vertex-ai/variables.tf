variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "location" {
  description = "The GCP location/region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "agent_display_name" {
  description = "Display name for the Vertex AI agent"
  type        = string
}

variable "agent_description" {
  description = "Description for the Vertex AI agent"
  type        = string
}

variable "staging_bucket_name" {
  description = "Name of the staging bucket"
  type        = string
}

variable "bigquery_dataset_id" {
  description = "BigQuery dataset ID for agent access"
  type        = string
  default     = null
}

variable "vertex_ai_models" {
  description = "List of Vertex AI models to use"
  type        = list(string)
  default     = []
}

variable "rag_corpus_id" {
  description = "RAG corpus ID for retrieval"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
