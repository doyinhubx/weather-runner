terraform {
  backend "gcs" {
    bucket = "weather-app-tfstate-v2"
    prefix = "dev"
  }
}