resource "google_compute_instance" "openclaw_backend" {
  count        = var.instance_count
  name         = "${var.instance_name_prefix}-${count.index + 1}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["openclaw-backend"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = var.disk_size_gb
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = var.backend_subnet_id
    # SIN access_config -> 100% aislada de Internet público. Solo accesible vía proxy/túnel.
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y docker.io jq curl
    sudo systemctl enable docker
    sudo systemctl start docker
    echo "Instancia aislada de OpenClaw lista para ejecucion 24/7 de usuario ${count.index + 1}"
  EOF

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  labels = {
    tier        = "openclaw-backend"
    multi_user  = "isolated-instance"
    cost_tier   = "micro-economic"
    user_id     = "user-${count.index + 1}"
  }
}
