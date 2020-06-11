locals {
  iam_server_service_account = var.server_service_account != ""

  iam_service_account = toset(compact([
    local.iam_server_service_account ? var.server_service_account : "",
    var.server_service_account_create ? google_service_account.server[0].email: ""
  ]))
}

# Roles for the Server service account
# c.f. https://blog.jetbrains.com/teamcity/2017/06/run-teamcity-ci-builds-in-google-cloud/
resource "google_project_iam_custom_role" "manage_agents" {
  count = var.server_service_account_create || local.iam_server_service_account ? 1 : 0

  role_id     = var.iam_custom_role_name
  title       = "TeamCity Google Cloud Agent Manager"
  description = "IAM role for TeamCity server to manage Google Cloud Agents"

  permissions = [
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

##############################################
# Separate Service Account for Server
##############################################
resource "google_service_account" "server" {
  count = var.server_service_account_create ? 1 : 0

  account_id   = var.server_service_account_name
  display_name = var.server_service_account_display

  project = var.project_id
}

##############################################
# Common IAM assignment
##############################################

resource "google_project_iam_member" "server_project_viewer" {
  for_each = local.iam_service_account

  role    = "roles/compute.viewer"
  project = var.project_id
  member  = "serviceAccount:${each.value}"
}

resource "google_project_iam_member" "server_cloud_agent_manager" {
  for_each = local.iam_service_account

  role    = google_project_iam_custom_role.manage_agents[0].id
  project = var.project_id
  member  = "serviceAccount:${each.value}"
}

# Conform to CIS 1.5
# This allow TC server's service account use TC agent's service account
resource "google_service_account_iam_member" "server_use_agent" {
  for_each = local.iam_service_account

  service_account_id = google_service_account.agent.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${each.value}"
}
