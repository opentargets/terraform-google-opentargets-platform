locals {
  // PROMETHEUS Communication Ports
  otp_prometheus_port      = 9090
  otp_grafana_port         = 3000
  otp_prometheus_port_name = "otpprometheusport"
  // Firewall
  fw_tag_otp_prometheus_node = "otpprometheusnode"
  // GLB tagging for traffic destination
  glb_tag_target_node = "otpprometheus-glb-target"
  // Load Balancer types
  lb_type_internal = "INTERNAL"
  lb_type_global   = "GLOBAL"
  lb_type_none     = "NONE"
  input_validation_load_balancer_type_allowed_values = [
    local.lb_type_internal,
    local.lb_type_global,
    local.lb_type_none
  ]
  // prometheus VM instance template values
  otpprometheus_template_tags = concat(
    var.vm_firewall_tags,
    [
      local.fw_tag_otp_prometheus_node, local.glb_tag_target_node
    ]
  )
  otpprometheus_template_machine_type = "custom-${var.vm_prometheus_vcpus}-${var.vm_prometheus_mem}"
  otpprometheus_template_source_image = "${var.vm_prometheus_image_project}/${var.vm_prometheus_image}"
  node_exporter_image                 = "${var.node_exporter_image_name}:${var.node_exporter_image_version}"
  prometheus_image                    = "${var.prometheus_image_name}:${var.prometheus_image_version}"
  grafana_image                       = "${var.grafana_image_name}:${var.grafana_image_version}"
}