resource "google_artifact_registry_repository" "weather_appv2" {
  location      = var.region
  repository_id = "weather-app-repov2"
  format        = "DOCKER"
}
