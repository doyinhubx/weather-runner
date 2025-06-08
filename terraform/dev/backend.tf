terraform {
  backend "gcs" {
    bucket = "weather-app-v2"  # Create this in GCP first
    prefix = "dev/cloudrun"
  }
}