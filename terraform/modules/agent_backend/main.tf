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

  # Configuración de Service Account para acceso nativo a GCP Vertex AI (Gemini)
  dynamic "service_account" {
    for_each = var.service_account_email != "" ? [var.service_account_email] : []
    content {
      email  = service_account.value
      scopes = ["cloud-platform"]
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-venv git curl jq

    # Crear entorno virtual e instalar FastAPI/Uvicorn
    mkdir -p /opt/openclaw
    python3 -m venv /opt/openclaw/venv
    /opt/openclaw/venv/bin/pip install --upgrade pip
    /opt/openclaw/venv/bin/pip install fastapi uvicorn pydantic requests

    # Descargar código del Agente OpenClaw con soporte Vertex AI
    cd /tmp
    git clone https://github.com/joanroamora/realStateAux.git || (cd realStateAux && git pull)
    cp /tmp/realStateAux/agent_engine/mock_openclaw/app.py /opt/openclaw/app.py

    # Crear servicio systemd para ejecución 24/7 en puerto 8080
    cat << 'SERVICE_EOF' | sudo tee /etc/systemd/system/openclaw-agent.service
    [Unit]
    Description=OpenClaw Agent Service (GCP Vertex AI)
    After=network.target

    [Service]
    User=root
    WorkingDirectory=/opt/openclaw
    Environment="VERTEX_AI_MODEL=gemini-1.5-flash"
    Environment="GCP_PROJECT_ID=bitcitychamp-project"
    Environment="DATA_API_URL=http://10.0.3.3:8000/api/v1"
    ExecStart=/opt/openclaw/venv/bin/uvicorn app:app --host 0.0.0.0 --port 8080
    Restart=always
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
    SERVICE_EOF

    sudo systemctl daemon-reload
    sudo systemctl enable openclaw-agent
    sudo systemctl start openclaw-agent
    echo "✅ Servicio OpenClaw + Vertex AI iniciado correctamente en el puerto 8080"
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
    ai_provider = "gcp-vertex-ai"
  }
}
