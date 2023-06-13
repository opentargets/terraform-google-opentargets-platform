// --- OpenAI API Compute resources --- //
resource "random_string" "openai_api_node" {
    length = 8
    special = false
    upper = false
    lower = true
    keepers = {
        template_tags = join("", sort(local.fw_vm_tags)),
        machine_type = local.vm_machine_type,
        source_image = local.vm_template_source_image,
        docker_fqdn_image = local.openai_api_docker_image,
        startup_script = md5(file("${path.module}/scripts/vm_startup.sh"))
    }
}

// Access to Available compute zones in the given region --- //
data "google_compute_zones" "available" {
  count = length(var.deployment_regions)

  region = var.deployment_regions[count.index]
}

// --- Service Account Configuration ---
resource "google_service_account" "gcp_service_acc_openai_api" {
  project      = var.project_id
  account_id   = "${var.module_wide_prefix_scope}-svcacc-${random_string.openai_api_node.result}"
  display_name = "${var.module_wide_prefix_scope}-GCP-service-account"
}

// Roles ---
resource "google_project_iam_member" "logging-writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gcp_service_acc_openai_api.email}"
}

resource "google_project_iam_member" "monitoring-writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gcp_service_acc_openai_api.email}"
}
// --- /Service Account Configuration/ ---

// OpenAI API Compute Instance (VM) ---