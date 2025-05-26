variable "project_id" {
  description = "Target GCP project ID (where Cloud Run is deployed)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "container_image" {
  description = "Full container image path (from source project)"
  type        = string
}

variable "source_project_id" {
  description = "Source project ID (where Artifact Registry lives)"
  type        = string
}

variable "source_repository" {
  description = "Artifact Registry repository name"
  type        = string
}

variable "target_project_number" {
  description = "Numeric project number of the target project"
  type        = string
}
