variable "project_id" {
  default = "galvanic-portal-456405-a2"
}

variable "region" {
  default     = "us-central1"
}


variable "db_instance_name" {
  default     = "my-postgres-instance"
}


variable "db_tier" {
  default     = "db-custom-2-7680"
}


variable "db_user" {
  default     = "postgres-user-test"
}


variable "db_password" {
  sensitive   = true
}


variable "cloud_run_image" {
  default     = "docker.io/dhilipakaran/testing:v1"
}


variable "cloud_run_service_name" {
  default = "my-app-db-test"
}
