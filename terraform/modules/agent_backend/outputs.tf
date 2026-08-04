output "backend_instance_ips" {
  value       = google_compute_instance.openclaw_backend[*].network_interface[0].network_ip
  description = "Lista de direcciones IP internas aisladas de las instancias de OpenClaw"
}

output "backend_instance_names" {
  value       = google_compute_instance.openclaw_backend[*].name
  description = "Nombres de las instancias de backend creadas"
}
