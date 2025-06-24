data "google_compute_image" "main" {
  family  = var.vm_api_image
  project = var.vm_api_image_project
}