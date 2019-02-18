resource "google_service_account" "agent" {
  account_id   = "${var.service_account_name}"
  display_name = "${var.service_account_display}"

  project = "${var.project_id}"
}
