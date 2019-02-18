variable "project_id" {
  description = "Project ID to deploy resources in"
}

variable "service_account_name" {
  description = "Name for the TeamCity agent service account"
  default     = "teamcity-agent"
}

variable "service_account_display" {
  description = "Display name for the TeamCity agent service account"
  default     = "Service Account for the TeamCity Agent"
}
