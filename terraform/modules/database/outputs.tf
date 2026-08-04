output "db_instance_name" {
  value       = google_compute_instance.db_instance.name
  description = "Nombre de la instancia de base de datos"
}

output "db_internal_ip" {
  value       = google_compute_instance.db_instance.network_interface[0].network_ip
  description = "IP privada de la base de datos (accesible únicamente dentro de la VPC)"
}

output "db_instance_self_link" {
  value       = google_compute_instance.db_instance.self_link
  description = "Self link de GCP para la instancia DB"
}
