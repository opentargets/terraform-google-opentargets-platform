locals {
 // --- VPC --- //
  vpc_network_name = "${var.config_release_name}-vpc"
  vpc_network_main_subnet_name = "main-subnet"
  vpc_network_region_subnet_map = zipmap(
    var.config_deployment_regions,
    [
      for idx, region in var.config_deployment_regions: {
        //subnet_name = local.vpc_main_subnetting_map[region]
        subnet_name = local.vpc_network_main_subnet_name
        subnet_region = region
        subnet_ip = "10.${idx}.0.0/20"
      }
    ]
  )
  
  // Firewall --- //
  // Target Tags
  fw_tag_ssh = "ssh"
  fw_tag_http = "http"
  fw_tag_https = "https"

  // --- DNS --- //
  // The effective DNS name is the one taking into account a possible subdomain that should scope the deployment
  dns_effective_dns_name = (var.config_dns_subdomain_prefix == null ? var.config_dns_managed_zone_dns_name : "${var.config_dns_subdomain_prefix}.${var.config_dns_managed_zone_dns_name}")
  dns_platform_api_dns_name = "${var.config_dns_platform_api_subdomain}.${local.dns_effective_dns_name}"
  dns_platform_webapp_domain_names = [
    "www.${local.dns_effective_dns_name}",
    local.dns_effective_dns_name
  ]

  // --- Folders --- //
  folder_tmp = abspath("${path.module}/tmp")

  // --- Global Load Balancer --- //
  // GLB tagging for traffic destination
  tag_glb_target_node = "glb-serve-target"
  glb_dns_platform_api_dns_names = [ trimsuffix(local.dns_platform_api_dns_name, ".") ]
  glb_dns_platform_webapp_domain_names = [ for hostname in local.dns_platform_webapp_domain_names: trimsuffix(hostname, ".") ]

  // --- Debugging --- // 
  canaryvm_zone = "${var.config_deployment_regions[0]}-b"
}