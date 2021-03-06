locals {
  // --- VPC --- //
  vpc_network_name             = "${var.config_release_name}-vpc"
  vpc_network_main_subnet_name = "main-subnet"
  vpc_network_region_subnet_map = zipmap(
    var.config_deployment_regions,
    [
      for idx, region in var.config_deployment_regions : {
        //subnet_name = local.vpc_main_subnetting_map[region]
        subnet_name   = local.vpc_network_main_subnet_name
        subnet_region = region
        subnet_ip     = "10.${idx}.0.0/20"
      }
    ]
  )

  // Firewall --- //
  // Target Tags
  fw_tag_ssh   = "ssh"
  fw_tag_http  = "http"
  fw_tag_https = "https"

  // --- DNS --- //
  // The effective DNS name is the one taking into account a possible subdomain that should scope the deployment
  dns_effective_dns_name    = (var.config_dns_subdomain_prefix == null ? var.config_dns_managed_zone_dns_name : "${var.config_dns_subdomain_prefix}.${var.config_dns_managed_zone_dns_name}")
  dns_platform_base_name    = "${var.config_dns_platform_subdomain}.${local.dns_effective_dns_name}"
  dns_platform_api_dns_name = "${var.config_dns_platform_api_subdomain}.${local.dns_platform_base_name}"
  dns_platform_webapp_domain_names = [
    "www.${local.dns_platform_base_name}",
    local.dns_platform_base_name
  ]

  // --- Folders --- //
  folder_tmp = abspath("${path.module}/tmp")

  // --- Global Load Balancer --- //
  // GLB tagging for traffic destination --- //
  tag_glb_target_node                  = "glb-serve-target"
  glb_dns_platform_api_dns_names       = [trimsuffix(local.dns_platform_api_dns_name, ".")]
  glb_dns_platform_webapp_domain_names = [for hostname in local.dns_platform_webapp_domain_names : trimsuffix(hostname, ".")]

  // SSL --- //
  ssl_managed_certificate_domain_names = concat(local.dns_platform_webapp_domain_names, [local.dns_platform_api_dns_name])

  // CDN for web app backend --- //
  glb_webapp_cdn_enabled             = var.config_glb_webapp_enable_cdn
  glb_netsec_effective_policy_api    = local.netsec_enable_policies_api ? google_compute_security_policy.netsec_policy_api[0].self_link : null
  glb_netsec_effective_policy_webapp = local.netsec_enable_policies_webapp ? google_compute_security_policy.netsec_policy_webapp[0].self_link : null

  //---  Network Security --- //
  netsec_enable_policies_api           = var.config_security_api_enable
  netsec_enable_policies_webapp        = var.config_security_webapp_enable
  netsec_restriction_source_ip_enabled = length(var.config_security_restrict_source_ips) == 0 ? false : true
  netsec_restriction_source_ip_cidrs   = var.config_security_restrict_source_ips

  // --- Debugging --- // 
  canaryvm_zone = "${var.config_deployment_regions[0]}-b"

  // --- Development Mode --- //
  dev_mode_on                     = var.config_set_dev_mode_on
  dev_mode_conditional_deployment = local.dev_mode_on ? 1 : 0
  dev_mode_fw_tags                = local.dev_mode_on ? [local.fw_tag_ssh] : []

  // --- Infrastructure Inspection Configuration --- //
  inspection_enabled                = var.config_enable_inspection
  inspection_conditional_deployment = local.inspection_enabled ? 1 : 0
}