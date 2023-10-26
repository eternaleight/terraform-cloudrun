variable "project_id" {
  description = "The GCP project ID"
}

variable "region" {
  description = "The GCP region"
  default     = "asia-northeast1"
}

variable "service_name" {
  description = "The name of the Cloud Run service"
  default     = "my-cloud-run-service"
}

variable "image" {
  description = "The image URL of the Cloud Run service"
}

