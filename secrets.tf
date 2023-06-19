// --- Open Targets Platform Operational Secrets --- //

// Random resource for secret ID
resource "random_string" "openai_token" {
  length  = 8
  special = false
  upper   = false
  lower   = true
  keepers = {
    secret_data = md5(local.credentials_openai_token)
  }
}

// --- OpenAI API --- //
resource "google_secret_manager_secret" "openai_api_token" {
  project = var.config_project_id

  secret_id = "openai-token-${random_string.openai_token.result}"
  replication {
    user_managed {
      replicas {
        location = "europe-west1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "openai_api_token" {
  secret      = google_secret_manager_secret.openai_api_token.id
  secret_data = local.credentials_openai_token
}

