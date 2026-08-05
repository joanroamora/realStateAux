resource "google_compute_instance" "db_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["private-db"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = var.disk_size_gb
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = var.db_subnet_id
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    # Crear Swap de 1GB para evitar OOM Killer en e2-micro (1GB RAM)
    sudo fallocate -l 1G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=1024
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile || true
    sudo swapon /swapfile || true

    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-venv git curl jq postgresql

    sudo mkdir -p /opt/realstate-api
    sudo python3 -m venv /opt/realstate-api/venv
    sudo /opt/realstate-api/venv/bin/pip install --no-cache-dir fastapi uvicorn pydantic

    sudo rm -rf /tmp/realStateAux
    sudo git clone https://github.com/joanroamora/realStateAux.git /tmp/realStateAux
    sudo cp -r /tmp/realStateAux/api/* /opt/realstate-api/
    sudo cp -r /tmp/realStateAux/data /opt/realstate-api/data

    cat << 'SERVICE_EOF' | sudo tee /etc/systemd/system/realstate-data-api.service
    [Unit]
    Description=RealState Data API Service
    After=network.target

    [Service]
    User=root
    WorkingDirectory=/opt/realstate-api
    ExecStart=/opt/realstate-api/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000
    Restart=always
    RestartSec=3

    [Install]
    WantedBy=multi-user.target
    SERVICE_EOF

    sudo systemctl daemon-reload
    sudo systemctl enable realstate-data-api
    sudo systemctl restart realstate-data-api
    echo "✅ Data API lista en puerto 8000"
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
