terraform {
  backend "gcs" {
    bucket = "weather-app-tfstate-v2" # overridden in CI
    prefix = "artifact-registry"
  }
}
