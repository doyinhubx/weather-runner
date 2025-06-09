terraform {
  backend "gcs" {
    bucket = "weather-app-tfstate-v2" # Overridden in CI
    prefix = "app"
  }
}
