// --- Open Targets Platform Network Security Policies --- //

// --- API Network Policies  --- //
resource "random_string" "random_netsec_policy_api" {
  length  = 8
  lower   = true
  upper   = false
  special = false
  keepers = {
    cidrs = md5(join("", local.netsec_restriction_source_ip_cidrs))
  }
}

resource "google_compute_security_policy" "netsec_policy_api" {
  count = local.netsec_enable_policies_api ? 1 : 0

  project     = var.config_project_id
  name        = "netsec-policy-api-${random_string.random_netsec_policy_api.result}"
  description = "Allow access to attached backends only from the given source CIDRs"

  // Traffic restriction from source CIDR
  dynamic "rule" {
    for_each = local.netsec_restriction_source_ip_enabled ? [1] : []
    content {
      description = "Allow traffic from the given list of CIDRs"
      action      = "allow"
      priority    = "1000"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = local.netsec_restriction_source_ip_cidrs
        }
      }
    }
  }
  dynamic "rule" {
    for_each = local.netsec_restriction_source_ip_enabled ? [1] : []
    content {
      description = "Overwrite default rule to block all traffic"
      action      = "deny(403)"
      priority    = "2147483647"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = ["*"]
        }
      }
    }
  }
  // TODO --- IDS/IPS Subsystem --- //

  lifecycle {
    create_before_destroy = true
  }
}

// --- Web Application Network Policies  --- //
resource "random_string" "random_netsec_policy_webapp" {
  length  = 8
  lower   = true
  upper   = false
  special = false
  keepers = {
    cidrs = md5(join("", local.netsec_restriction_source_ip_cidrs))
  }
}

resource "google_compute_security_policy" "netsec_policy_webapp" {
  count = local.netsec_enable_policies_webapp ? 1 : 0

  project     = var.config_project_id
  name        = "netsec-policy-webapp-${random_string.random_netsec_policy_webapp.result}"
  description = "Allow access to attached backends only from the given source CIDRs"

  // Traffic restriction from source CIDR
  dynamic "rule" {
    for_each = local.netsec_restriction_source_ip_enabled ? [1] : []
    content {
      action   = "allow"
      priority = "1000"
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = local.netsec_restriction_source_ip_cidrs
        }
      }
    }
  }
  dynamic "rule" {
    for_each = local.netsec_restriction_source_ip_enabled ? [1] : []
    content {
      action   = "deny(403)"
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

  lifecycle {
    create_before_destroy = true
  }
}
