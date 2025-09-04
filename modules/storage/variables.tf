variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "location" {
  description = "The GCP location/region"
  type        = string
}

variable "staging_bucket_name" {
  description = "Name of the staging bucket"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_versioning" {
  description = "Enable versioning on the storage bucket"
  type        = bool
  default     = true
}

variable "lifecycle_days" {
  description = "Number of days after which objects are deleted"
  type        = number
  default     = 30
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the bucket"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels to apply to resources (alias for tags)"
  type        = map(string)
  default     = {}
}
