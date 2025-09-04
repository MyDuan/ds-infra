# Composition Variables
# These variables are specific to the DS Agent composition

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "location" {
  description = "The GCP region/location"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = can(regex("^(dev|staging|prod)$", var.environment))
    error_message = "Environment must be dev, staging, or prod."
  }
}

# Agent Configuration
variable "agent_display_name" {
  description = "Display name for the Vertex AI agent"
  type        = string
  default     = "Data Science Agent"
}

variable "agent_description" {
  description = "Description for the Vertex AI agent"
  type        = string
  default     = "An AI agent for data science tasks with BigQuery integration"
}

# Storage Configuration
variable "staging_bucket_name" {
  description = "Name for the staging bucket"
  type        = string
  default     = null # Will be auto-generated if not provided
}

variable "enable_versioning" {
  description = "Enable versioning on the staging bucket"
  type        = bool
  default     = true
}

variable "storage_bucket_lifecycle_days" {
  description = "Number of days after which to delete old versions"
  type        = number
  default     = 30
}

# BigQuery Configuration
variable "bq_dataset_id" {
  description = "BigQuery dataset ID"
  type        = string
}

variable "bq_dataset_location" {
  description = "BigQuery dataset location"
  type        = string
  default     = "US"
}

# Vertex AI Configuration
variable "vertex_ai_models" {
  description = "List of Vertex AI models to configure"
  type        = list(string)
  default     = [
    "gemini-2.0-flash-exp"
  ]
}

# RAG Configuration
variable "rag_corpus_id" {
  description = "RAG corpus ID (optional)"
  type        = string
  default     = null
}

# Data Science Agent Setup
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

# Security and Compliance
variable "enable_deletion_protection" {
  description = "Enable deletion protection for critical resources"
  type        = bool
  default     = false
}

# Tagging
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Component = "ds-agent"
  }
}
