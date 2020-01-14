locals {
  # Conform to CIS 4.2
  required_metadata = {
    "block-project-ssh-keys" = "true"
  }

  instance_image = coalesce(
    var.instance_image,
    data.google_compute_image.agent.self_link,
  )
}

resource "google_service_account" "agent" {
  account_id   = var.service_account_name
  display_name = var.service_account_display

  project = var.project_id
}

resource "google_project_iam_member" "project" {
  for_each = var.service_account_roles

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.agent.email}"
}

resource "google_service_account" "server" {
  count = var.server_service_account_create ? 1 : 0

  account_id   = var.server_service_account_name
  display_name = var.server_service_account_display

  project = var.project_id
}

# Roles for the Server service account
# c.f. https://blog.jetbrains.com/teamcity/2017/06/run-teamcity-ci-builds-in-google-cloud/
resource "google_project_iam_custom_role" "manage_agents" {
  role_id     = "${replace(var.server_service_account_name, "-", "_")}_cloud_agent_manager"
  title       = "TeamCity Google Cloud Agent Manager"
  description = "IAM role for TeamCity server to manage Google Cloud Agents"

  permissions = [
    // "roles/compute.instanceAdmin",
    "compute.disks.create",
    "compute.diskTypes.list",
    "compute.images.list",
    "compute.images.useReadOnly",
    "compute.instances.create",
    "compute.instances.delete",
    "compute.instances.list",
    "compute.instances.setLabels",
    "compute.instances.setMetadata",
    "compute.instances.setServiceAccount",
    "compute.instanceTemplates.get",
    "compute.instanceTemplates.list",
    "compute.instanceTemplates.useReadOnly",
    "compute.machineTypes.list",
    "compute.networks.list",
    "compute.subnetworks.list",
    "compute.zones.list",
  ]
}

resource "google_project_iam_member" "server_project_viewer" {
  count = var.server_service_account_create ? 1 : 0

  role    = "roles/viewer"
  project = var.project_id
  member  = "serviceAccount:${google_service_account.server[0].email}"
}

resource "google_project_iam_member" "server_cloud_agent_manager" {
  count = var.server_service_account_create ? 1 : 0

  role    = google_project_iam_custom_role.manage_agents.id
  project = var.project_id
  member  = "serviceAccount:${google_service_account.server[0].email}"
}

# Conform to CIS 1.5
# This allow TC server's service account use TC agent's service account
resource "google_service_account_iam_member" "server_use_agent" {
  service_account_id = google_service_account.agent.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.server[0].email}"
}

data "google_compute_image" "agent" {
  family  = var.image_family
  project = var.project_id
}

resource "google_compute_instance_template" "agent" {
  count = var.instance_subnetworks_count

  project = var.project_id
  region  = var.region

  name_prefix          = var.instance_template_prefix
  description          = var.instance_template_description
  instance_description = var.instance_description

  machine_type            = var.machine_type
  labels                  = var.labels
  metadata                = merge(var.metadata, local.required_metadata)
  metadata_startup_script = var.metadata_startup_script
  tags                    = var.tags

  disk {
    boot         = true
    auto_delete  = true
    source_image = local.instance_image
    disk_type    = var.disk_type
    disk_size_gb = var.disk_size_gb
  }

  network_interface {
    subnetwork         = element(var.instance_subnetworks, count.index)
    subnetwork_project = element(var.instance_subnetworks_projects, count.index)
    # No external IP for now
    # access_config {}
  }

  service_account {
    email = google_service_account.agent.email

    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}
