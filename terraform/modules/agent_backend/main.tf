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
  }

  dynamic "service_account" {
    for_each = var.service_account_email != "" ? [var.service_account_email] : []
    content {
      email  = service_account.value
      scopes = ["cloud-platform"]
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    # Crear Swap de 1GB para evitar OOM Killer en e2-micro (1GB RAM)
    sudo fallocate -l 1G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=1024
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile || true
    sudo swapon /swapfile || true

    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-venv git curl jq

    sudo mkdir -p /opt/openclaw
    sudo python3 -m venv /opt/openclaw/venv
    sudo /opt/openclaw/venv/bin/pip install --no-cache-dir fastapi uvicorn pydantic requests google-genai

    sudo rm -rf /tmp/realStateAux
    sudo git clone https://github.com/joanroamora/realStateAux.git /tmp/realStateAux
    sudo cp /tmp/realStateAux/agent_engine/mock_openclaw/app.py /opt/openclaw/app.py

    cat << 'SERVICE_EOF' | sudo tee /etc/systemd/system/openclaw-agent.service
    [Unit]
    Description=OpenClaw Agent Service (Google Gemini LLM)
    After=network.target

    [Service]
    User=root
    WorkingDirectory=/opt/openclaw
    Environment="GEMINI_API_KEY=${var.gemini_api_key}"
    Environment="GCP_PROJECT_ID=431641823853"
    Environment="DATA_API_URL=http://10.0.3.5:8000/api/v1"
    ExecStart=/opt/openclaw/venv/bin/uvicorn app:app --host 0.0.0.0 --port 8080
    Restart=always
    RestartSec=3

    [Install]
    WantedBy=multi-user.target
    SERVICE_EOF

    sudo systemctl daemon-reload
    sudo systemctl enable openclaw-agent
    sudo systemctl restart openclaw-agent
    echo "✅ Servicio OpenClaw + Google Gemini API listo en puerto 8080"
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
    ai_provider = "google-gemini-llm"
  }
}
