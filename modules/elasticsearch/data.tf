data "google_compute_image" "main" {
  family  = var.vm_elastic_search_image
  project = var.vm_elastic_search_image_project
}