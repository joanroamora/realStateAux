variable "network_name" {
  type        = string
  description = "Nombre de la VPC"
}

variable "frontend_subnet_cidr" {
  type        = string
  description = "Rango de IP de la subred frontend pública"
}

variable "backend_subnet_cidr" {
  type        = string
  description = "Rango de IP de la subred protegida de agentes"
}

variable "db_subnet_cidr" {
  type        = string
  description = "Rango de IP de la subred privada de datos"
}

variable "db_port" {
  type        = number
  description = "Puerto de la base de datos de bajo costo (ej. 5432 PostgreSQL, 3306 MySQL, 8000 API privada)"
  default     = 5432
}

variable "agent_backend_port" {
  type        = number
  description = "Puerto donde escucha la API interna del backend de OpenClaw"
  default     = 8080
}
