resource "google_artifact_registry_repository" "weather_appv2" {
  provider      = google
  location      = var.region
  repository_id = "weather-app-repov2"
  format        = "DOCKER"
  project       = var.project_id
  mode          = "STANDARD_REPOSITORY"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [labels]
  }
}
