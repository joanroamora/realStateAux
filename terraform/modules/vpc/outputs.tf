output "vpc_id" {
  value       = google_compute_network.vpc_network.id
  description = "ID de la VPC principal"
}

output "vpc_name" {
  value       = google_compute_network.vpc_network.name
  description = "Nombre de la VPC principal"
}

output "frontend_subnet_id" {
  value       = google_compute_subnetwork.public_frontend_subnet.id
  description = "ID de la subred frontend"
}

output "frontend_subnet_cidr" {
  value       = google_compute_subnetwork.public_frontend_subnet.ip_cidr_range
  description = "CIDR de la subred frontend"
}

output "backend_subnet_id" {
  value       = google_compute_subnetwork.protected_backend_subnet.id
  description = "ID de la subred protegida de agentes backend"
}

output "backend_subnet_cidr" {
  value       = google_compute_subnetwork.protected_backend_subnet.ip_cidr_range
  description = "CIDR de la subred protegida de agentes backend"
}

output "db_subnet_id" {
  value       = google_compute_subnetwork.private_db_subnet.id
  description = "ID de la subred privada de base de datos"
}

output "db_subnet_cidr" {
  value       = google_compute_subnetwork.private_db_subnet.ip_cidr_range
  description = "CIDR de la subred privada de base de datos"
}
