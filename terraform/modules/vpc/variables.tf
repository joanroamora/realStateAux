variable "network_name" {
  type        = string
  description = "Nombre de la VPC principal"
  default     = "realstate-vpc"
}

variable "region" {
  type        = string
  description = "Región de GCP donde desplegar las subredes"
  default     = "us-central1"
}

variable "frontend_subnet_cidr" {
  type        = string
  description = "CIDR para la subred pública/frontend"
  default     = "10.0.1.0/24"
}

variable "backend_subnet_cidr" {
  type        = string
  description = "CIDR para la subred protegida de agentes OpenClaw"
  default     = "10.0.2.0/24"
}

variable "db_subnet_cidr" {
  type        = string
  description = "CIDR para la subred privada de base de datos"
  default     = "10.0.3.0/24"
}
