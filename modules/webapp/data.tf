data "google_compute_image" "main" {
  family      = var.webserver_vm_image
  project     = var.webserver_vm_image_project
  most_recent = true
}