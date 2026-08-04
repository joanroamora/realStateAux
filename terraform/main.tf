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

# 4. Módulo Agentes OpenClaw: Instancias aisladas para multi-usuario
module "agent_backend" {
  source               = "./modules/agent_backend"
  instance_count       = var.backend_instance_count
  instance_name_prefix = "openclaw-user-agent"
  zone                 = var.zone
  machine_type         = var.backend_machine_type
  backend_subnet_id    = module.vpc.backend_subnet_id
  disk_size_gb         = 10
}
