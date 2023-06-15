// --- Open Targets Platform Operational Secrets --- //

// --- OpenAI API --- //
resource "google_secret_manager_secret" "openai_api_token" {
    project = var.config_project_id

    secret_id = "openai-api-token"
    replication {
        user_managed {
            replicas {
                location = "europe-west1"
            }
        }
    }
}

resource "google_secret_manager_secret_version" "openai_api_token" {
    secret = google_secret_manager_secret.openai_api_token.id
    secret_data = "${local.credentials_openai_token}"
}

