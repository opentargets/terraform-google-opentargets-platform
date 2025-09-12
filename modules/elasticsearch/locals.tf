locals {
  // Ports
  elastic_search_port_requests           = 9200
  elastic_search_port_comms              = 9300
  elastic_search_port_exporter           = 9114
  elastic_search_port_node_exporter      = 9100
  elastic_search_port_requests_name      = "esportrequests"
  elastic_search_port_comms_name         = "esportcomms"
  elastic_search_port_node_exporter_name = "esportexnodeporter"
  elastic_search_port_exporter_name      = "esportexporter"
  // Firewall tags
  fw_tag_elasticsearch_requests = "elasticsearchrequests"
  fw_tag_elasticsearch_comms    = "elasticsearchcomms"

  // Elastic Search instance template values
  elastic_search_template_tags = concat(
    var.vm_firewall_tags,
    [
      local.fw_tag_elasticsearch_requests,
      local.fw_tag_elasticsearch_comms
    ]
  )
  elastic_search_template_machine_type = "custom-${var.vm_elastic_search_vcpus}-${var.vm_elastic_search_mem}"
  // Compute Zones internal parameters
  compute_zones_n_total = length(data.google_compute_zones.available.names)
  // Elastic Search Data Volume
  elastic_search_data_disk_snapshot = "projects/open-targets-eu-dev/global/snapshots/${var.vm_elastic_search_data_volume_snapshot}"
  // Clickhouse data disk device name
  elastic_search_data_disk_device = "es-data"
  // Google Device Disk prefix
  gcp_device_disk_prefix = "/dev/disk/by-id/google-"

  node_exporter_image    = "${var.node_exporter_image_name}:${var.node_exporter_image_version}"
  elastic_exporter_image = "${var.elastic_exporter_image_name}:${var.elastic_exporter_image_version}"
  alloy_container        = "${var.alloy_image_name}:${var.alloy_image_version}"
  alloy_endpoint         = "http://${var.observabilty_servers[0]}:3100/loki/api/v1/push"
}