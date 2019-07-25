resource "google_compute_resource_policy" "teamcity_server_data" {
  provider = "google-beta"

  name    = "scheduled-snapshot-for-${google_compute_disk.teamcity_server_data.name}"
  project = var.project_id

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time = "20:00"
      }
    }
    retention_policy {
      max_retention_days = 5
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
    snapshot_properties {
      labels = var.labels
      storage_locations = ["asia-southeast1"]
      guest_flush = false
    }
  }
}
