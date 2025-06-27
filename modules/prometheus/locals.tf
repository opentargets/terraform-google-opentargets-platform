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
}