output "service_url" {
  value = google_cloud_run_service.weather_app_devv2.status[0].url
}

