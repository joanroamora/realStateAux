variable "project_id" {
  type        = string
  description = "ID del proyecto en Google Cloud Platform (GCP)"
}

variable "region" {
  type        = string
  description = "Región de GCP para el despliegue (ej. us-central1)"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "Zona de GCP para las instancias de cómputo (ej. us-central1-a)"
  default     = "us-central1-a"
}

variable "environment" {
  type        = string
  description = "Ambiente de ejecución (ej. dev, staging, prod)"
  default     = "prod"
}

variable "network_name" {
  type        = string
  description = "Nombre de la red VPC aislada"
  default     = "realstate-vpc-prod"
}

variable "db_machine_type" {
  type        = string
  description = "Tipo de máquina para la base de datos de bajo costo"
  default     = "e2-micro"
}

variable "backend_machine_type" {
  type        = string
  description = "Tipo de máquina para cada instancia aislada de OpenClaw"
  default     = "e2-micro"
}

variable "backend_instance_count" {
  type        = number
  description = "Número inicial de agentes/instancias aisladas de usuarios"
  default     = 1
}
