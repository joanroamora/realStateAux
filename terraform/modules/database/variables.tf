variable "instance_name" {
  type        = string
  description = "Nombre de la instancia de base de datos"
  default     = "realstate-db-micro"
}

variable "zone" {
  type        = string
  description = "Zona de GCP donde desplegar la instancia de base de datos"
  default     = "us-central1-a"
}

variable "machine_type" {
  type        = string
  description = "Tipo de maquina virtual ultra eficiente y economica"
  default     = "e2-micro"
}

variable "db_subnet_id" {
  type        = string
  description = "ID de la subred privada de base de datos"
}

variable "disk_size_gb" {
  type        = number
  description = "Tamaño de disco minimo en GB para optimizar costos"
  default     = 10
}

variable "environment" {
  type        = string
  description = "Entorno de despliegue (ej. dev, prod)"
  default     = "prod"
}
