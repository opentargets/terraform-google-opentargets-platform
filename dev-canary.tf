// --- This file contains resources that will be activated when development mode is 'ON', for debugging purposes --- //
// Canary for the infrastructure mine --- //
resource "google_compute_instance" "inspection_vm" {
  // This definition will deploy a small VM in each deployment region for debugging communication and other infrastructure issues
  count = length(var.config_deployment_regions) * local.inspection_conditional_deployment

  name = "inspection-vm-${count.index}"
  machine_type = "e2-small"
  zone = "${var.config_deployment_regions[count.index]}-b"
  depends_on = [ module.vpc_network ]

  boot_disk {
    initialize_params {
        image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = module.vpc_network.network_self_link
    subnetwork = "main-subnet"
  }

  tags = [ "ssh" ]
}
