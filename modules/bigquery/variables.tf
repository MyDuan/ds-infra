variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "dataset_id" {
  description = "BigQuery dataset ID"
  type        = string
}

variable "dataset_location" {
  description = "BigQuery dataset location"
  type        = string
  default     = "US"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vertex_ai_sa_email" {
  description = "Vertex AI service account email"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on tables"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
