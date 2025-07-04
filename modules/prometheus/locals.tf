locals {
  // PROMETHEUS Communication Ports
  otp_prometheus_port      = 9090
  otp_grafana_port         = 3000
  otp_prometheus_port_name = "otpprometheusport"
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
}