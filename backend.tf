terraform {
  backend "gcs" {
    bucket = "backend_state"
    # prefix is passed at init time via -backend-config
  }
}
