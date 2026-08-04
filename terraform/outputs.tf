output "vpc_name" {
  value       = module.vpc.vpc_name
  description = "Nombre de la VPC creada"
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
  value = <<-EOF
    ===============================================================
    RESUMEN DE OPTIMIZACIÓN DE COSTOS DE INFRAESTRUCTURA (GCP)
    ===============================================================
    - DB Machine: e2-micro (2 vCPU, 1GB RAM) -> ~$7 USD/mes o Elegible para GCP Free Tier
    - Agent VMs: e2-micro por usuario -> ~$7 USD/mes por usuario
    - Storage: Standard Persistent Disk (10GB pd-standard) -> ~$0.40 USD/mes por disco
    - IP Pública: Sin IPs externas asignadas a DB ni Agentes (Ahorro de ~$3.60/mes por IP)
    - Acceso Administrativo: SSH a través de GCP IAP (Sin costo de Bastion ni IPs)
    ===============================================================
  EOF
  description = "Detalle de optimización de costos en GCP"
}
