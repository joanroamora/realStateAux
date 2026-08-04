resource "google_compute_instance" "db_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["private-db"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = var.disk_size_gb
      type  = "pd-standard" # Disco estandar para optimizacion de costos
    }
  }

  network_interface {
    subnetwork = var.db_subnet_id
    # SIN access_config -> Sin IP pública para garantir aislamiento total
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y postgresql postgresql-contrib jq
    sudo systemctl enable postgresql
    sudo systemctl start postgresql
    echo "Base de datos privada lista en instancia economica e2-micro"
  EOF

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  labels = {
    environment = var.environment
    tier        = "database"
    cost_tier   = "micro-economic"
  }
}
