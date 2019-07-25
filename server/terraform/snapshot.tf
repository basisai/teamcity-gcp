locals {
  policy_name = "scheduled-snapshot-for-${google_compute_disk.teamcity_server_data.name}"
}

resource "null_resource" "unattach_policy" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    name               = local.policy_name
    project            = var.project_id
    region             = var.region
    max_retention_days = var.max_retention_days
    days_in_cycle      = var.snapshot_days_in_cycle
    start_time         = var.snapshot_start_time
  }

   provisioner "local-exec" {
    command = "gcloud beta compute disks remove-resource-policies $DISK_NAME --resource-policies $SCHEDULE_NAME --zone $ZONE || true"

     environment = {
      DISK_NAME = google_compute_disk.teamcity_server_data.self_link
      SCHEDULE_NAME = local.policy_name
      ZONE = google_compute_disk.teamcity_server_data.zone
    }
  }
}

resource "google_compute_resource_policy" "teamcity_server_data" {
  provider = "google-beta"

  name    = local.policy_name
  project = var.project_id
  region  = var.region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = var.snapshot_days_in_cycle
        start_time = var.snapshot_start_time
      }
    }
    retention_policy {
      max_retention_days = var.max_retention_days
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
    snapshot_properties {
      labels = merge(var.labels, { checksum = null_resource.unattach_policy.id })
      storage_locations = [var.region]
      guest_flush = false
    }
  }

  provisioner "local-exec" {
    command = "gcloud beta compute disks add-resource-policies $DISK_NAME --resource-policies $SCHEDULE_NAME --zone $ZONE"

    environment = {
      DISK_NAME = google_compute_disk.teamcity_server_data.self_link
      SCHEDULE_NAME = local.policy_name
      ZONE = google_compute_disk.teamcity_server_data.zone
    }
  }
}
