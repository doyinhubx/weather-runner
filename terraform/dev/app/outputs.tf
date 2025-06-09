output "service_url" {
  description = "URL of deployed Cloud Run service"
  value       = google_cloud_run_service.weather_app_devv2.status[0].url
}
