data "google_compute_image" "main" {
  family  = var.vm_image
  project = var.vm_image_project
}