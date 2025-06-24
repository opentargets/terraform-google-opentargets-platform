data "google_compute_image" "main" {
  family  = var.vm_prometheus_image
  project = var.vm_prometheus_image_project
}