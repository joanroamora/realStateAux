resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
  description             = "VPC aislada para el Asistente Inmobiliario Autónomo (OpenClaw + GCP)"
}

# Subred pública para Frontend / Proxy inverso
resource "google_compute_subnetwork" "public_frontend_subnet" {
  name                     = "${var.network_name}-public-frontend"
  ip_cidr_range            = var.frontend_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

# Subred protegida para Backends de Agentes OpenClaw
resource "google_compute_subnetwork" "protected_backend_subnet" {
  name                     = "${var.network_name}-protected-backend"
  ip_cidr_range            = var.backend_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

# Subred privada para la Capa de Datos (Base de Datos de Bajo Costo)
resource "google_compute_subnetwork" "private_db_subnet" {
  name                     = "${var.network_name}-private-db"
  ip_cidr_range            = var.db_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

# Router y Cloud NAT opcional para actualizaciones de agentes sin exponer IPs públicas en backend
resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.protected_backend_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
