// --- Open Targets Platform Network Security Policies --- //

// --- Apply Traffic Origin Restrictions --- //
// Allowed CIDRs --- //
resource "random_string" "random_netsec_rule_source_ip_allow" {
  length = 8
  lower = true
  upper = false
  special = false
  keepers = {
    cidrs = md5(join("", local.netsec_restriction_source_ip_cidrs))
  }
}

resource "google_compute_security_policy" "netsec_rule_source_ip_allow" {
  count = local.netsec_restriction_source_ip_enabled ? 1 : 0

  project = var.config_project_id
  name = "netsec-allow-cidrs-${random_string.random_netsec_rule_source_ip_allow.result}"
  description = "Allow access to attached backends from the given source CIDRs"

  rule {
    action = "allow"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = local.netsec_restriction_source_ip_cidrs
      }
    }
  }
}

resource "google_compute_security_policy" "netsec_rule_default_deny" {
  count = local.netsec_restriction_source_ip_enabled ? 1 : 0

  project = var.config_project_id
  name = "netsec-default-deny-${random_string.random_netsec_rule_source_ip_allow.result}"
  description = "Default rule, 'deny'"

  rule {
    action = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}

// TODO --- IDS/IPS Subsystem --- //