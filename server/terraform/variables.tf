variable "name" {
  description = "Base name of resources"
  default     = "teamcity-server"
}

variable "description" {
  description = "Description for resources"
  default     = "TeamCity Server"
}

variable "region" {
  description = "Default region for GCP"
}

variable "zone" {
  description = "Zone to launch instance in"
}

variable "tags" {
  description = "Tags for the instance"
  default     = []
}

variable "machine_type" {
  description = "Machine type of the instance"
  default     = "n1-standard-1"
}

variable "labels" {
  description = "Labels of the instance"
  default     = {}
}

variable "metadata" {
  description = "Metadata for the instances"
  default     = {}
}

variable "boot_disk_size_gb" {
  description = "Size of the boot disk in GB"
  default     = "50"
}

variable "boot_disk_type" {
  description = "Type of the boot disk"
  default     = "pd-standard"
}

variable "boot_disk_image" {
  description = "Use this image as the boot disk instead of the default family"
  default     = ""
}

variable "boot_disk_family" {
  description = "Image family to search for boot disk"
  default     = "teamcity-server"
}

variable "boot_disk_image_project" {
  description = "Project containing the boot disk image if different from `project_id`"
  default     = ""
}

variable "project_id" {
  description = "Project ID for resources"
}

variable "subnetwork" {
  default = "Subnetwork to attach the instance to"
}

variable "network_ip" {
  description = "Static internal IP if needed"
  default     = ""
}

variable "allow_stopping_for_update" {
  description = "f true, allows Terraform to stop the instance to update its properties. If you try to update a property that requires stopping the instance without setting this field, the update will fail."
  default     = "true"
}

variable "teamcity_image" {
  description = "TeamCity image to run"
  default     = "jetbrains/teamcity-server"
}

variable "teamcity_tag" {
  description = "TeamCity image tag to run"
  default     = "2018.2.2"
}

variable "teamcity_port" {
  description = "Port to expose TeamCity"
  default     = 80
}

variable "data_disk_name" {
  description = "Name of the data disk"
  default     = "teamcity-server-data"
}

variable "data_disk_size" {
  description = "Size of the data disk in GB"
  default     = "100"
}

variable "data_disk_type" {
  description = "Type of the data disk to create"
  default     = "pd-ssd"
}

variable "teamcity_memory_options" {
  description = "Memory options for TeamCity. See https://confluence.jetbrains.com/display/TCD18/Installing+and+Configuring+the+TeamCity+Server#InstallingandConfiguringtheTeamCityServer-SettingUpMemorysettingsforTeamCityServer"
  default     = "-Xmx1024m"
}

variable "snapshot_days_in_cycle" {
  description = "Days between snapshots"
  default     = 1
}

variable "snapshot_start_time" {
  description = "This must be in UTC format that resolves to one of 00:00, 04:00, 08:00, 12:00, 16:00, or 20:00. For example, both 13:00-5 and 08:00 are valid."
  default     = "20:00"
}

variable "max_retention_days" {
  description = "Maximum age of the snapshot that is allowed to be kept."
  default     = 5
}
