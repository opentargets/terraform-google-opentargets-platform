locals {
  // Ports
  elastic_search_port_requests      = 9200
  elastic_search_port_comms         = 9300
  elastic_search_port_requests_name = "esportrequests"
  elastic_search_port_comms_name    = "esportcomms"
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
  elastic_search_template_source_image = "${var.vm_elastic_search_image_project}/${var.vm_elastic_search_image}"
  // Compute Zones internal parameters
  compute_zones_n_total = length(data.google_compute_zones.available.names)
  // Elastic Search Data Volume
  elastic_search_data_disk_snapshot = "global/snapshots/${var.vm_elastic_search_data_volume_snapshot}"
  // Clickhouse data disk device name
  elastic_search_data_disk_device = "es-data"
  // Google Device Disk prefix
  gcp_device_disk_prefix = "/dev/disk/by-id/google-"
}