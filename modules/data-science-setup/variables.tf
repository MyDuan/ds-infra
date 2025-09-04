variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "location" {
  description = "The GCP location/region"
  type        = string
}

variable "dataset_id" {
  description = "BigQuery dataset ID"
  type        = string
  default     = "forecasting_sticker_sales"
}

variable "agent_source_path" {
  description = "Path to the data science agent source code"
  type        = string
}

variable "staging_bucket_name" {
  description = "Name of the staging bucket"
  type        = string
}

variable "force_rag_corpus_recreation" {
  description = "Force recreation of RAG corpus"
  type        = bool
  default     = false
}

variable "deploy_to_agent_engine" {
  description = "Whether to deploy to Agent Engine"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
