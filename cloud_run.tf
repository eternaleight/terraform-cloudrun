resource "google_cloud_run_service" "default" {
  name     = var.service_name
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/${var.service_name}"
        
        ports {
          container_port = 8001
        }

        resources {
          limits = {
            memory = "128Mi"
            cpu    = "1"
          }
        }
      }
      service_account_name = google_service_account.cloud_run_service_account.email
      container_concurrency = 80
      timeout_seconds = 300
    }
  }

  autogenerate_revision_name = true
  traffic {
    percent         = 100
    latest_revision = true
  }

  metadata {
    annotations = {
      "autoscaling.knative.dev/minScale" = "0"
      "autoscaling.knative.dev/maxScale" = "1"
    }
  }
}

resource "google_service_account" "cloud_run_service_account" {
  account_id   = "cloud-run-service-account"
  display_name = "Cloud Run Service Account"
}

resource "google_cloudbuild_trigger" "github_trigger" {
  name = "github-trigger"
  description = "Trigger for GitHub commits"
  
  github {
    owner = var.github_owner
    name = var.github_repo
    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"
}
