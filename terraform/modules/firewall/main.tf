# Regla 1: Permitir tráfico web público (HTTP/HTTPS) ÚNICAMENTE hacia el Frontend Público
resource "google_compute_firewall" "allow_public_frontend" {
  name    = "${var.network_name}-allow-public-frontend"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "3000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["frontend-proxy"]
  description   = "Permite trafico web publico unicamente a la capa de frontend proxy"
}

# Regla 2: Permitir tráfico al backend OpenClaw ÚNICAMENTE desde la Subred / Tag Frontend
resource "google_compute_firewall" "allow_frontend_to_backend" {
  name    = "${var.network_name}-allow-frontend-to-backend"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = [tostring(var.agent_backend_port)]
  }

  # Permitir unicamente desde la IP/rango de la subred del frontend
  source_ranges = [var.frontend_subnet_cidr]
  target_tags   = ["openclaw-backend"]
  description   = "Aísla OpenClaw permitiendo tráfico exclusivamente proveniente del frontend"
}

# Regla 3: Permitir tráfico a la Base de Datos privada ÚNICAMENTE desde el Frontend Público / Proxy
resource "google_compute_firewall" "allow_frontend_to_db" {
  name    = "${var.network_name}-allow-frontend-to-db"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = [tostring(var.db_port)]
  }

  # Accesible únicamente desde las subredes autorizadas (Frontend / Proxy)
  source_ranges = [var.frontend_subnet_cidr, var.backend_subnet_cidr]
  target_tags   = ["private-db"]
  description   = "Restringe el acceso a la base de datos de bajo costo únicamente desde la subred frontend"
}

# Regla 4: Bloquear explícitamente todo ingreso de Internet a la capa Backend y DB
resource "google_compute_firewall" "deny_internet_to_backend_db" {
  name    = "${var.network_name}-deny-internet-to-internal"
  network = var.network_name
  priority = 2000

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["openclaw-backend", "private-db"]
  description   = "Deniega acceso directo desde internet a instancias aisladas"
}

# Regla 5: Permitir SSH seguro ÚNICAMENTE vía GCP IAP (Identity-Aware Proxy)
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.network_name}-allow-iap-ssh"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Bloque de IP oficial de GCP Identity-Aware Proxy
  source_ranges = ["35.190.247.0/20"]
  target_tags   = ["frontend-proxy", "openclaw-backend", "private-db"]
  description   = "Permite SSH seguro sin IP pública expuesta mediante Google Cloud IAP"
}
