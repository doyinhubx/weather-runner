output "cloud_run_url" {
  description = "URL of the deployed Cloud Run service"
  value       = google_cloud_run_service.weather_app2_dev.status[0].url
}

output "service_account_email" {
  description = "Created service account email"
  value       = google_service_account.weather_app2_sa.email
}
