variable "instance_name" {
  type        = string
  description = "Nombre de la instancia de frontend proxy público"
  default     = "realstate-frontend-proxy"
}

variable "zone" {
  type        = string
  description = "Zona GCP de despliegue"
  default     = "us-central1-a"
}

variable "machine_type" {
  type        = string
  description = "Tipo de máquina e2-micro para máximo ahorro"
  default     = "e2-micro"
}

variable "frontend_subnet_id" {
  type        = string
  description = "ID de la subred pública frontend"
}

variable "disk_size_gb" {
  type        = number
  description = "Tamaño de disco en GB"
  default     = 10
}

variable "environment" {
  type        = string
  description = "Ambiente de ejecución"
  default     = "prod"
}
