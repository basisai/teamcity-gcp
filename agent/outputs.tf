output "service_account_id" {
  description = "Service Account ID for TeamCity agent"
  value       = google_service_account.agent.account_id
}

output "service_account_name" {
  description = "Service Account name for TeamCity agent"
  value       = google_service_account.agent.name
}

output "service_account_email" {
  description = "Service Account email for TeamCity agent"
  value       = google_service_account.agent.email
}

output "server_service_account_name" {
  description = "Service Account name for TeamCity server"
  value       = google_service_account.server[0].name
}

output "server_service_account_email" {
  description = "Service Account email for TeamCity server"
  value       = google_service_account.server[0].email
}

output "instance_template" {
  description = "Self-link to the instance template"
  value       = google_compute_instance_template.agent[0].self_link
}
