// --- Open Targets Platform Grafana Passwords Secrets --- //

// Random resource for secret ID
resource "random_string" "grafana_password" {
  length  = 8
  special = false
  upper   = false
  lower   = true
  keepers = {
    secret_data = md5(random_password.grafana_password.bcrypt_hash)
  }
}

resource "random_password" "grafana_password" {
  length  = 12
  special = false
}

resource "google_secret_manager_secret" "grafana_password" {
  project = var.project_id

  secret_id = "grafana-password-${random_string.grafana_password.result}"

  replication {
    user_managed {
      replicas {
        location = "europe-west1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "grafana_password" {
  secret = google_secret_manager_secret.grafana_password.id

  secret_data = random_password.grafana_password.result
}