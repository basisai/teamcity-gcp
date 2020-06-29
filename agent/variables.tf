variable "project_id" {
  description = "Project ID to deploy resources in"
}

variable "region" {
  description = "An instance template is a global resource that is not bound to a zone or a region. However, you can still specify some regional resources in an instance template, which restricts the template to the region where that resource resides. For example, a custom subnetwork resource is tied to a specific region. Defaults to the region of the Provider if no value is given."
  default     = ""
}

variable "service_account_name" {
  description = "Name for the TeamCity agent service account"
  default     = "teamcity-agent"
}

variable "service_account_roles" {
  description = "Roles for the Agent Service Account"
  type        = set(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]
}

variable "service_account_display" {
  description = "Display name for the TeamCity agent service account"
  default     = "Service Account for the TeamCity Agent"
}

variable "server_service_account_create" {
  description = "Create a separate service account for TeamCity server to manage instances with the GCP plugin. You will need to create a separate key for this service account and enter it into TeamCity UI"
  default     = false
}

variable "iam_custom_role_name" {
  description = "Name of the IAM Custom role to manage the agents"
  default     = "teamcity_server_cloud_agent_manager"
}

variable "server_service_account_name" {
  description = "Service account for TeamCity server to manage instances"
  default     = "teamcity-server"
}

variable "server_service_account_display" {
  description = "Display name for the TeamCity server service account"
  default     = "Service Account for the TeamCity Server to manage agents"
}

variable "server_service_account" {
  description = "If non-empty, will assign roles to the server service account directly"
  default     = ""
}

variable "instance_template_prefix" {
  description = "Prefix of the instance template for agents"
  default     = "teamcity-agent"
}

variable "instance_template_description" {
  description = "Description for the instance template"
  default     = "Instance template for TeamCity agents"
}

variable "instance_description" {
  description = "Description for instance created from the template"
  default     = "TeamCity agent"
}

variable "image_family" {
  description = "Image family of the TeamCity agent"
}

variable "instance_image" {
  description = "Set this to override using the latest image from the image family. Should be a self_link"
  default     = ""
}

variable "machine_type" {
  description = "Machine type for the agent"
  default     = "n1-standard-1"
}

variable "labels" {
  description = " Labels for instances created from the template"

  default = {
    terraform = "true"
  }
}

variable "metadata" {
  description = "Metadata for instances created from this template"
  default     = {}
}

variable "metadata_startup_script" {
  description = "Startup script for the instance"
  default     = ""
}

variable "tags" {
  description = "List of tags for the instance"
  default     = []
}

variable "disk_type" {
  description = "Disk type for the instance"
  default     = "pd-ssd"
}

variable "disk_size_gb" {
  description = "Disk size in GB for the instance"
  default     = "100"
}

variable "disk_encryption_key" {
  description = "CMEK for disk, if any"
  default     = ""
}

variable "instance_subnetworks" {
  description = "List of subnetworks to create the instances in"
  type        = list(string)
}

variable "instance_subnetworks_projects" {
  description = "List of projects matching the subnetworks in `instance_subnetworks`"
  type        = list(string)
}

variable "instance_subnetworks_count" {
  description = "Number of subnetworks to create the instances in"
}
