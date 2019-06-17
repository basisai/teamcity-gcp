output "instance_self_link" {
  description = "Self link of the instance"
  value       = google_compute_instance.teamcity_server.self_link
}

output "service_account_email" {
  description = "Email address of the service account used for the instance"
  value       = google_service_account.teamcity_server.email
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = google_compute_instance.teamcity_server.network_interface[0].network_ip
}

output "public_ip" {
  description = "Private IP address of the instance"
  value       = google_compute_instance.teamcity_server.network_interface[0].access_config[0].nat_ip
}
