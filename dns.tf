// --- DNS Configuration --- //
// Entry for Open Target API GLB
resource "google_dns_record_set" "dns_a_api_glb" {
  // Common
  managed_zone = var.config_dns_managed_zone_name
  type = "A"
  ttl = 300

  // Entry
  name = local.dns_platform_api_dns_name
  rrdatas = [ module.glb_platform.external_ip ]
}

// Entry for Open Targets Platform Web Application
resource "google_dns_record_set" "dns_a_webapp_glb" {
    count = length(local.dns_platform_webapp_domain_names)
    // Common
    managed_zone = var.config_dns_managed_zone_name
    type = "A"
    ttl = 300
    // Entry
    name = local.dns_platform_webapp_domain_names[count.index]
    rrdatas = [ module.glb_platform.external_ip ]
}