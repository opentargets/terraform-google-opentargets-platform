// --- Open Targets Platform Network Security Policies --- //

// --- API Network Policies  --- //
resource "random_string" "random_netsec_policy_api" {
  length  = 8
  lower   = true
  upper   = false
  special = false
  keepers = {
    cidrs   = md5("${join("", local.netsec_allowed_cidrs)} + ${join("", local.netsec_blocked_cidrs)}")
    enabled = local.netsec_enable_policies_api
  }
}

resource "google_compute_security_policy" "netsec_policy_api" {
  count = local.netsec_enable_policies_api ? 1 : 0

  project     = var.config_project_id
  name        = "netsec-policy-api-${random_string.random_netsec_policy_api.result}"
  description = "Allow access to attached backends only from the given source CIDRs"

  // Traffic restriction from source CIDR
  // Blocked CIDRs
  dynamic "rule" {
    for_each = local.netsec_enable_policies_api ? local.netsec_blocked_cidrs_policy_listings : []
    content {
      description = "Blocked-listed API traffic from the given list of CIDRs, group #${rule.key}"
      action      = "deny(403)"
      priority    = rule.key + 1000
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = rule.value
        }
      }
    }
  }
  // Allowed CIDRs
  dynamic "rule" {
    for_each = local.netsec_enable_policies_api ? local.netsec_allowed_cidrs_policy_listings : []
    content {
      description = "Allow API traffic from the given list of CIDRs, group #${rule.key}"
      action      = "allow"
      priority    = rule.key + 1001 + length(local.netsec_blocked_cidrs_policy_listings)
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = rule.value
        }
      }
    }
  }
  // Default rule to block all traffic
  dynamic "rule" {
    for_each = local.netsec_enable_policies_api ? [1] : []
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
    cidrs   = md5("${join("", local.netsec_allowed_cidrs)} + ${join("", local.netsec_blocked_cidrs)}")
    enabled = local.netsec_enable_policies_webapp
  }
}

resource "google_compute_security_policy" "netsec_policy_webapp" {
  count = local.netsec_enable_policies_webapp ? 1 : 0

  project     = var.config_project_id
  name        = "netsec-policy-webapp-${random_string.random_netsec_policy_webapp.result}"
  description = "Allow access to attached backends only from the given source CIDRs"

  // Traffic restriction from source CIDR
  // Blocked CIDRs
  dynamic "rule" {
    for_each = local.netsec_enable_policies_webapp ? local.netsec_blocked_cidrs_policy_listings : []
    content {
      description = "Blocked-listed WEB traffic from the given list of CIDRs, group #${rule.key}"
      action      = "redirect"
      priority    = rule.key + 1000
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = rule.value
        }
      }
      redirect_options {
        type   = "EXTERNAL_302"
        target = "https://platform.opentargets.org/unauthorized.html"
      }
    }
  }
  // Allowed CIDRs
  dynamic "rule" {
    for_each = local.netsec_enable_policies_webapp ? local.netsec_allowed_cidrs_policy_listings : []
    content {
      description = "Allow WEB traffic from the given list of CIDRs, group #${rule.key}"
      action      = "allow"
      priority    = rule.key + 1001 + length(local.netsec_blocked_cidrs_policy_listings)
      match {
        versioned_expr = "SRC_IPS_V1"
        config {
          src_ip_ranges = rule.value
        }
      }
    }
  }
  // Redirect rule for root path
  dynamic "rule" {
    for_each = local.netsec_enable_policies_webapp ? [1] : []
    content {
      description = "Redirect requests for '/' to '/unauthorized.html'"
      action      = "redirect"
      priority    = "2147483646"
      match {
        expr {
          expression = "request.path == '/'"
        }
      }
      redirect_options {
        type   = "EXTERNAL_302"
        target = "https://platform.opentargets.org/unauthorized.html"
      }
    }
  }
  // Default rule to block all traffic
  dynamic "rule" {
    for_each = local.netsec_enable_policies_webapp ? [1] : []
    content {
      description = "Redirect requests for '/' to '/unauthorized.html'"
      action      = "redirect"
      priority    = "2147483646"
      match {
        expr {
          expression = "request.path == '/'"
        }
      }
      redirect_options {
        type = "EXTERNAL_302"
        target = "https://platform.opentargets.org/unauthorised.html"
      }
    }
  }
  dynamic "rule" {
    for_each = local.netsec_enable_policies_webapp ? [1] : []
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
