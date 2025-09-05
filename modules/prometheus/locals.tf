locals {
  // PROMETHEUS Communication Ports
  otp_prometheus_port      = 9090
  otp_grafana_port         = 3000
  otp_prometheus_port_name = "otpprometheusport"
  otp_prometheus_disk_name = "prometheus-data"
  // Firewall
  fw_tag_otp_prometheus_node = "otpprometheusnode"
  // GLB tagging for traffic destination
  glb_tag_target_node = "otpprometheus-glb-target"
  // prometheus VM instance template values
  otpprometheus_template_tags = concat(
    var.vm_firewall_tags,
    [
      local.fw_tag_otp_prometheus_node, local.glb_tag_target_node
    ]
  )
  otpprometheus_machine_type = var.vm_prometheus_type
  node_exporter_image        = "${var.node_exporter_image_name}:${var.node_exporter_image_version}"
  prometheus_image           = "${var.prometheus_image_name}:${var.prometheus_image_version}"
  grafana_image              = "${var.grafana_image_name}:${var.grafana_image_version}"

  // calculate md5 for each dashboard to deploy when there's a change in the dashboards
  dashboards     = fileset("${path.module}/config/dashboards", "*.json")
  dashboards_md5 = zipmap(local.dashboards, [for dashboard in local.dashboards : md5(file("${path.module}/config/dashboards/${dashboard}"))])
  zones          = flatten(data.google_compute_zones.available[*].names)

  prometheus_svc_key = replace(base64decode(google_service_account_key.gcp_service_acc_prom_key.private_key), "$", "\\$")

  loki_container  = "${var.loki_image_name}:${var.loki_image_version}"
  alloy_container = "${var.alloy_image_name}:${var.alloy_image_version}"

  // Node exporter configuration Start
  //relabling configuration
  relabeling_config = [{
    source_labels = ["__meta_gce_instance_name"]
    target_label  = "nodename"
  }]
  // API scraping configuration
  api_scraping_gce_config = [for zone in local.zones :
    {
      zone    = zone
      project = var.project_id
      port    = 8080
      filter  = "(name:${var.module_wide_prefix_api}*)"
    }
  ]
  api_scraping_config = {
    job_name        = "api"
    relabel_configs = local.relabeling_config
    gce_sd_configs  = local.api_scraping_gce_config
  }
  // node exporter scraping configuration
  node_exporter_scraping_gce_config = [for zone in local.zones :
    {
      zone    = zone
      project = var.project_id
      port    = 9100
      filter  = "(name:${var.config_release_name}*)"
    }
  ]
  node_exporter_scraping_config = {
    job_name        = "node"
    relabel_configs = local.relabeling_config
    gce_sd_configs  = local.node_exporter_scraping_gce_config
  }
  // opensearch exporter scraping configuration
  opensearch_exporter_scraping_gce_config = [for zone in local.zones :
    {
      zone    = zone
      project = var.project_id
      port    = 9114
      filter  = "(name:${var.module_wide_prefix_es}*)"
    }
  ]
  opensearch_exporter_scraping_config = {
    job_name        = "opensearch"
    relabel_configs = local.relabeling_config
    gce_sd_configs  = local.opensearch_exporter_scraping_gce_config
  }
  // clickhouse exporter scraping configuration
  clickhouse_exporter_scraping_gce_config = [for zone in local.zones :
    {
      zone    = zone
      project = var.project_id
      port    = 9363
      filter  = "(name:${var.module_wide_prefix_ch}*)"
    }
  ]
  clickhouse_exporter_scraping_config = {
    job_name        = "clickhouse"
    relabel_configs = local.relabeling_config
    gce_sd_configs  = local.clickhouse_exporter_scraping_gce_config
  }
  prometheus_exporter_scraping_config = {
    job_name        = "prometheus"
    relabel_configs = local.relabeling_config
    static_configs = [
      {
        targets = ["localhost:9090"]
      }
    ]
  }
  // Prometheus configuration file
  prometheus_config_file = {
    global = {
      scrape_interval = "15s"
    }
    scrape_configs = [
      local.api_scraping_config,
      local.node_exporter_scraping_config,
      local.prometheus_exporter_scraping_config,
      local.opensearch_exporter_scraping_config,
      local.clickhouse_exporter_scraping_config
    ]
  }
  // Node exporter configuration End
}