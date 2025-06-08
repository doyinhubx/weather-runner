terraform {
  backend "gcs" {
    bucket = "YOUR_TERRAFORM_STATE_BUCKET"  # Create this in GCP first
    prefix = "dev/cloudrun"
  }
}