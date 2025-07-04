data "google_compute_image" "main" {
  family  = var.vm_clickhouse_image
  project = var.vm_clickhouse_image_project
}