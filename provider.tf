provider "google" {
  credentials = file("<PATH_TO_YOUR_SERVICE_ACCOUNT_KEY_JSON>")
  project     = "<YOUR_GCP_PROJECT_ID>"
  region      = "asia-northeast1"
}

