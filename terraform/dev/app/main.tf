provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_cloud_run_service" "weather_app_devv2" {
  name     = "weather-app-devv2"
  location = var.region

  template {
    spec {
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_repo}/weather-appv2:${var.image_tag}"
        ports {
          container_port = 8080
        }
        env {
          name  = "NODE_ENV"
          value = "dev"
        }
      }
      timeout_seconds = 300
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Correct lifecycle policy
  lifecycle {
    ignore_changes = [
      # Add any attributes that might change externally
      # template[0].spec[0].containers[0].image
    ]
  }
}

resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.weather_app_devv2.name
  location = google_cloud_run_service.weather_app_devv2.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}