output "service_account_name" {
  description = "Service Account name for TeamCity agent"
  value       = "${google_service_account.agent.name}"
}

output "service_account_email" {
  description = "Service Account email for TeamCity agent"
  value       = "${google_service_account.agent.email}"
}

output "server_service_account_name" {
  description = "Service Account name for TeamCity server"
  value       = "${google_service_account.server.name}"
}

output "server_service_account_email" {
  description = "Service Account email for TeamCity server"
  value       = "${google_service_account.server.email}"
}

output "instance_template" {
  description = "Self-link to the instance template"
  value       = "${google_compute_instance_template.agent.self_link}"
}
