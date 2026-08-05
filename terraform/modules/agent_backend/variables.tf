variable "instance_count" {
  type        = number
  description = "Cantidad de instancias aisladas de OpenClaw a desplegar (una por usuario/agente)"
  default     = 1
}

variable "instance_name_prefix" {
  type        = string
  description = "Prefijo para los nombres de las instancias de backend aisladas"
  default     = "openclaw-agent"
}

variable "zone" {
  type        = string
  description = "Zona GCP de despliegue"
  default     = "us-central1-a"
}

variable "machine_type" {
  type        = string
  description = "Tipo de máquina e2-micro para máximo ahorro por usuario"
  default     = "e2-micro"
}

variable "backend_subnet_id" {
  type        = string
  description = "ID de la subred protegida de backend"
}

variable "disk_size_gb" {
  type        = number
  description = "Tamaño de disco mínimo por instancia aislada"
  default     = 10
}

variable "service_account_email" {
  type        = string
  description = "Email de la Service Account de GCP con permisos para Vertex AI"
  default     = ""
}

variable "gemini_api_key" {
  type        = string
  description = "Clave de API de Google Gemini"
  default     = ""
  sensitive   = true
}

