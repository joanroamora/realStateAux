output "public_ip" {
  value       = google_compute_instance.frontend_proxy.network_interface[0].access_config[0].nat_ip
  description = "Dirección IP Pública Externa del Frontend en la Nube GCP"
}

output "instance_name" {
  value       = google_compute_instance.frontend_proxy.name
  description = "Nombre de la instancia de frontend proxy público"
}
