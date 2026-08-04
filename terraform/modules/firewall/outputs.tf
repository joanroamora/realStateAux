output "frontend_firewall_rule" {
  value       = google_compute_firewall.allow_public_frontend.name
  description = "Nombre de la regla de firewall del frontend"
}

output "backend_firewall_rule" {
  value       = google_compute_firewall.allow_frontend_to_backend.name
  description = "Nombre de la regla de firewall del backend aislada"
}

output "db_firewall_rule" {
  value       = google_compute_firewall.allow_frontend_to_db.name
  description = "Nombre de la regla de firewall de la base de datos privada"
}
