terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Habilitar API de GCP Vertex AI para razonamiento LLM nativo de OpenClaw
resource "google_project_service" "vertex_ai_api" {
  project            = var.project_id
  service            = "aiplatform.googleapis.com"
  disable_on_destroy = false
}

# Service Account para otorgar permisos a OpenClaw para consumir Gemini en Vertex AI sin API keys expuestas
resource "google_service_account" "openclaw_vertex_sa" {
  account_id   = "openclaw-vertex-agent-sa"
  display_name = "OpenClaw Agent Vertex AI Service Account"
  project      = var.project_id
}

# Rol de IAM para consumo de modelos en Vertex AI (Vertex AI User)
resource "google_project_iam_member" "vertex_ai_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.openclaw_vertex_sa.email}"
}

# 1. Módulo VPC: Red personalizada con subredes aisladas
module "vpc" {
  source       = "./modules/vpc"
  network_name = var.network_name
  region       = var.region
}

# 2. Módulo Firewall: Reglas de aislamiento estricto
module "firewall" {
  source               = "./modules/firewall"
  network_name         = module.vpc.vpc_name
  frontend_subnet_cidr = module.vpc.frontend_subnet_cidr
  backend_subnet_cidr  = module.vpc.backend_subnet_cidr
  db_subnet_cidr       = module.vpc.db_subnet_cidr
  db_port              = 5432
  agent_backend_port   = 8080
}

# 3. Módulo Base de Datos: Instancia e2-micro de bajo costo en subred privada
module "database" {
  source        = "./modules/database"
  instance_name = "realstate-db-micro"
  zone          = var.zone
  machine_type  = var.db_machine_type
  db_subnet_id  = module.vpc.db_subnet_id
  disk_size_gb  = 10
  environment   = var.environment
}

# 4. Módulo Agentes OpenClaw: Instancias aisladas para multi-usuario con acceso a Vertex AI
module "agent_backend" {
  source                = "./modules/agent_backend"
  instance_count        = var.backend_instance_count
  instance_name_prefix  = "openclaw-user-agent"
  zone                  = var.zone
  machine_type          = var.backend_machine_type
  backend_subnet_id     = module.vpc.backend_subnet_id
  disk_size_gb          = 10
  service_account_email = google_service_account.openclaw_vertex_sa.email
  gemini_api_key        = var.gemini_api_key
  depends_on            = [google_project_service.vertex_ai_api]
}

# 5. Módulo Frontend Público: Instancia e2-micro expuesta en IP Pública GCP
module "frontend_proxy" {
  source             = "./modules/frontend_proxy"
  instance_name      = "realstate-frontend-proxy"
  zone               = var.zone
  machine_type       = "e2-micro"
  frontend_subnet_id = module.vpc.frontend_subnet_id
  disk_size_gb       = 10
  environment        = var.environment
}
