locals {
  policy_name = "scheduled-snapshot-for-${var.data_disk_name}"
}

resource "google_compute_resource_policy" "teamcity_server_data" {
  name    = local.policy_name
  project = var.project_id
  region  = var.region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = var.snapshot_days_in_cycle
        start_time    = var.snapshot_start_time
      }
    }
    retention_policy {
      max_retention_days    = var.max_retention_days
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
    snapshot_properties {
      labels            = var.labels
      storage_locations = [var.region]
      guest_flush       = false
    }
  }
}

resource "google_compute_disk_resource_policy_attachment" "teamcity_server_data" {
  zone    = var.zone
  project = var.project_id
  disk    = google_compute_disk.teamcity_server_data.name
  name    = google_compute_resource_policy.teamcity_server_data.name
}
