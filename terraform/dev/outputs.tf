output "service_url" {
  value = google_cloud_run_service.weather_app_devv2.status[0].url
}

output "artifact_repo_name" {
  value = google_artifact_registry_repository.weather_appv2.repository_id
}