data "google_compute_image" "debian" {
  family  = var.vm_image
  project = var.vm_image_project
}