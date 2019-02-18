output "service_account_name" {
  description = "Service Account name for TeamCity agent"
  value       = "${google_service_account.agent.name}"
}

output "service_account_email" {
  description = "Service Account email for TeamCity agent"
  value       = "${google_service_account.agent.email}"
}
