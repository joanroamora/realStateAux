output "vpc_name" {
  value       = module.vpc.vpc_name
  description = "Nombre de la VPC creada"
}

output "frontend_public_ip" {
  value       = module.frontend_proxy.public_ip
  description = "Dirección IP Pública Externa del servicio expuesto en la Nube (GCP)"
}

output "frontend_public_url" {
  value       = "http://${module.frontend_proxy.public_ip}"
  description = "URL Pública para acceder a la aplicación desde cualquier navegador en Internet"
}

output "private_db_internal_ip" {
  value       = module.database.db_internal_ip
  description = "IP privada de la base de datos (accesible únicamente desde la subred autorizada)"
}

output "openclaw_backend_internal_ips" {
  value       = module.agent_backend.backend_instance_ips
  description = "IPs privadas aisladas de los agentes OpenClaw"
}

output "cost_optimization_summary" {
  value       = <<-EOF
    ===============================================================
    RESUMEN DE OPTIMIZACIÓN DE COSTOS DE INFRAESTRUCTURA (GCP)
    ===============================================================
    - Frontend Proxy VM: e2-micro (2 vCPU, 1GB RAM) con IP Pública Externa
    - DB Machine: e2-micro (2 vCPU, 1GB RAM) -> IP Privada Aislada (Free Tier)
    - Agent VMs: e2-micro por usuario -> IP Privada Aislada (Vertex AI Gemini 1.5)
    - Storage: Standard Persistent Disk (10GB pd-standard) -> ~$0.40 USD/mes por disco
    - Acceso Administrativo: SSH a través de GCP IAP (Sin costo de Bastion)
    ===============================================================
  EOF
  description = "Detalle de optimización de costos en GCP"
}
