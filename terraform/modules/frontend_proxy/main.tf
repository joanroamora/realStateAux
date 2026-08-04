resource "google_compute_instance" "frontend_proxy" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["frontend-proxy"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = var.disk_size_gb
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = var.frontend_subnet_id

    # ASIGNA IP PÚBLICA EXTERNA PARA ACCESO DESDE INTERNET
    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y nginx curl jq
    sudo systemctl enable nginx
    sudo systemctl start nginx
    echo "Frontend Proxy Público desplegado con éxito en IP Pública GCP"
  EOF

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  labels = {
    tier        = "public-frontend"
    cost_tier   = "micro-economic"
    environment = var.environment
  }
}
