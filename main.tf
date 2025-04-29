provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_sql_database_instance" "postgres_instance" {
  name              = var.db_instance_name
  database_version  = "POSTGRES_16"
  region            = var.region

  settings {
    tier = var.db_tier

    ip_configuration {
      ipv4_enabled    = true
      authorized_networks {
        name  = "allow-all"
        value = "0.0.0.0/0"  # Use this cautiously for public access; for private IP, use private network instead
      }
    }

    backup_configuration {
      enabled = true
    }
  }

  deletion_protection = false
}


resource "google_sql_user" "postgres_user" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres_instance.name
  password = var.db_password
}


resource "google_cloud_run_service" "my-app" {
  name     = var.cloud_run_service_name
  location = "us-central1"

  template {
    spec {
      containers {
        image = var.cloud_run_image
        ports {
          container_port = 8080
        }


        env {
          name  = "DB_CONNECTION_NAME"
          value = google_sql_database_instance.postgres_instance.connection_name
        }

        env {
          name  = "DB_USER"
          value = google_sql_user.postgres_user.name
        }

        env {
          name  = "DB_PASSWORD"
          value = "dbtesting"
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}


resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_service.my-app.location
  service  = google_cloud_run_service.my-app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}


output "cloud_run_url" {
  value = google_cloud_run_service.my-app.status[0].url
}
