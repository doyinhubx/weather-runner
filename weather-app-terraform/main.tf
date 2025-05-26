terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
}

# Enable necessary APIs
resource "google_project_service" "enabled_services" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com"
  ])
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# Create service account
resource "google_service_account" "weather_app2_sa" {
  account_id   = "weather-app2-sa"
  display_name = "Weather App 2 Service Account"
}

# Assign roles to service account
resource "google_project_iam_member" "weather_app2_sa_roles" {
  for_each = toset([
    "roles/artifactregistry.reader",
    "roles/cloudbuild.builds.editor",
    "roles/cloudbuild.serviceAgent",
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/storage.admin"
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.weather_app2_sa.email}"
}

# Deploy Cloud Run service
resource "google_cloud_run_service" "weather_app2_dev" {
  name     = "weather-app2-dev"
  location = var.region
  project  = var.project_id

  depends_on = [
    google_project_service.enabled_services,
    google_project_iam_member.weather_app2_sa_roles
  ]

  template {
    spec {
      service_account_name = google_service_account.weather_app2_sa.email
      containers {
        image = var.container_image
        ports {
          container_port = 8080
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Grant Artifact Registry Reader role across projects (cross-project pull)
resource "google_artifact_registry_repository_iam_member" "cross_project_pull" {
  project    = var.source_project_id
  location   = var.region
  repository = var.source_repository
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${var.target_project_number}@serverless-robot-prod.iam.gserviceaccount.com"

  depends_on = [google_project_service.enabled_services]
}

# Allow public (unauthenticated) access
resource "google_cloud_run_service_iam_member" "public_invoker" {
  service  = google_cloud_run_service.weather_app2_dev.name
  location = google_cloud_run_service.weather_app2_dev.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}