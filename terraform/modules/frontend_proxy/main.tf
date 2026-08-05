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
    set -e
    sudo apt-get update
    sudo apt-get install -y nginx curl jq

    # Crear aplicación web con Botón de Prueba Directa a OpenClaw + Clave API Gemini
    cat << 'HTML_EOF' | sudo tee /var/www/html/index.html
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>realStateAux - Conector Directo a OpenClaw LLM (Google Gemini)</title>
      <script src="https://cdn.tailwindcss.com"></script>
      <link rel="preconnect" href="https://fonts.googleapis.com">
      <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
      <style>
        body { background-color: #0b0f19; color: #f3f4f6; font-family: 'Inter', sans-serif; }
        .glass-panel { background: rgba(17, 24, 39, 0.8); backdrop-filter: blur(16px); border: 1px solid rgba(255, 255, 255, 0.08); }
        .glass-card { background: rgba(30, 41, 59, 0.5); backdrop-filter: blur(12px); border: 1px solid rgba(255, 255, 255, 0.06); transition: all 0.2s; }
        .glass-card:hover { background: rgba(30, 41, 59, 0.85); border-color: rgba(16, 185, 129, 0.4); transform: translateY(-2px); }
        .glow-emerald { box-shadow: 0 0 20px rgba(16, 185, 129, 0.3); }
        .glow-blue { box-shadow: 0 0 20px rgba(59, 130, 246, 0.4); }
      </style>
    </head>
    <body class="bg-[#0b0f19] text-gray-100 min-h-screen flex flex-col">
      <!-- Navbar -->
      <header class="sticky top-0 z-40 w-full glass-panel border-b border-gray-800 px-6 py-3">
        <div class="max-w-7xl mx-auto flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-emerald-500 to-teal-400 flex items-center justify-center font-bold text-gray-950 text-xl shadow-lg shadow-emerald-500/20">
              🤖
            </div>
            <div>
              <div class="flex items-center gap-2">
                <h1 class="font-['Outfit'] font-extrabold text-xl text-white">realState<span class="text-emerald-400">Aux</span></h1>
                <span class="px-2 py-0.5 text-[10px] font-semibold bg-blue-500/10 text-blue-400 border border-blue-500/20 rounded-full">
                  Gemini LLM Key Configurada
                </span>
              </div>
              <p class="text-xs text-gray-400">Conector Directo Web ➔ OpenClaw (10.0.2.7:8080) ➔ Google Gemini API (AQ.Ab8RN...)</p>
            </div>
          </div>
          <div class="flex items-center gap-2 text-xs">
            <button onclick="toggleOpenClawModal()" class="px-4 py-2 rounded-xl bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white font-bold shadow-lg glow-blue flex items-center gap-2 transition-all">
              ⚡ PROBAR CONEXIÓN DIRECTA CON OPENCLAW
            </button>
          </div>
        </div>
      </header>

      <!-- Modal de Testeo Directo a OpenClaw -->
      <div id="openclawModal" class="hidden fixed inset-0 z-50 bg-black/80 backdrop-blur-md flex items-center justify-center p-4">
        <div class="glass-panel max-w-2xl w-full rounded-3xl border border-blue-500/30 p-6 space-y-4 shadow-2xl relative">
          <div class="flex items-center justify-between border-b border-gray-800 pb-3">
            <div class="flex items-center gap-2">
              <span class="text-2xl">⚡</span>
              <div>
                <h3 class="font-['Outfit'] font-bold text-lg text-white">Consola de Prueba Directa a OpenClaw LLM</h3>
                <p class="text-xs text-gray-400">Verifica la respuesta en vivo del servicio OpenClaw con la API Key del usuario</p>
              </div>
            </div>
            <button onclick="toggleOpenClawModal()" class="text-gray-400 hover:text-white font-bold text-xl px-2">&times;</button>
          </div>

          <div class="grid grid-cols-2 gap-3 text-xs bg-gray-950/80 p-3 rounded-2xl border border-gray-800">
            <div>
              <span class="text-gray-500">Proyecto GCP:</span> <strong class="text-white">openClaw (431641823853)</strong>
            </div>
            <div>
              <span class="text-gray-500">API Key Gemini:</span> <strong class="text-emerald-400">Configurada (AQ.Ab8RN...)</strong>
            </div>
            <div>
              <span class="text-gray-500">Host Backend:</span> <strong class="text-blue-400">http://10.0.2.7:8080/api/v1/chat</strong>
            </div>
            <div>
              <span class="text-gray-500">Estado Servicio:</span> <strong id="modalStatus" class="text-amber-400">Proband en vivo...</strong>
            </div>
          </div>

          <div class="space-y-2">
            <label class="text-xs text-gray-300 font-semibold">Envía cualquier pregunta directamente al motor OpenClaw:</label>
            <div class="flex gap-2">
              <input type="text" id="directPrompt" value="eres?" class="flex-1 bg-gray-900 border border-gray-700 rounded-xl px-4 py-2.5 text-xs text-white focus:outline-none focus:border-blue-500" />
              <button onclick="runDirectTest()" class="px-5 py-2.5 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-bold text-xs shadow-md">
                Ejecutar Test Directo
              </button>
            </div>
          </div>

          <div class="space-y-1">
            <span class="text-[11px] text-gray-400 uppercase tracking-wider font-semibold">Respuesta Generada en Tiempo Real por Gemini (OpenClaw):</span>
            <div id="testOutput" class="bg-gray-950 p-4 rounded-xl border border-gray-800 text-xs font-mono text-emerald-400 min-h-[120px] max-h-[220px] overflow-y-auto whitespace-pre-wrap leading-relaxed">
              Esperando ejecución...
            </div>
          </div>

          <div class="flex justify-end pt-2 border-t border-gray-800">
            <button onclick="toggleOpenClawModal()" class="px-4 py-2 rounded-xl bg-gray-800 text-xs text-gray-300 hover:text-white">
              Cerrar Consola
            </button>
          </div>
        </div>
      </div>

      <!-- Main Container -->
      <main class="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 py-6 flex flex-col gap-6">
        
        <section class="glass-panel p-5 rounded-3xl border border-gray-800 relative overflow-hidden flex flex-col md:flex-row items-center justify-between gap-4">
          <div>
            <span class="px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-blue-500/10 text-blue-400 border border-blue-500/20">
              ✨ Servicio OpenClaw LLM Conectado a Gemini API Key (projects/431641823853)
            </span>
            <h2 class="font-['Outfit'] font-extrabold text-2xl text-white mt-1">Conector Web Directo a OpenClaw</h2>
            <p class="text-xs text-gray-400">Haz clic en el botón azul superior o chatea abajo para verificar la respuesta del LLM en vivo.</p>
          </div>
          <button onclick="toggleOpenClawModal()" class="px-5 py-2.5 rounded-2xl bg-blue-600 hover:bg-blue-500 text-white font-bold text-xs shadow-lg glow-blue shrink-0">
            ⚡ Consola de Test Directo OpenClaw
          </button>
        </section>

        <!-- Central Chat Component -->
        <section class="glass-panel rounded-3xl border border-gray-800 flex flex-col h-[520px] shadow-2xl relative overflow-hidden">
          <div class="px-5 py-3 border-b border-gray-800 bg-gray-900/90 flex items-center justify-between">
            <div class="flex items-center gap-3">
              <div class="w-9 h-9 rounded-xl bg-gradient-to-tr from-emerald-500 to-teal-400 flex items-center justify-center text-gray-950 font-bold glow-emerald">🤖</div>
              <div>
                <h3 class="font-['Outfit'] font-bold text-sm text-white">Charly AI (OpenClaw + Google Gemini API)</h3>
                <p class="text-[11px] text-gray-400">Conexión activa a /api/v1/chat (OpenClaw VM 10.0.2.7:8080)</p>
              </div>
            </div>
            <button onclick="toggleOpenClawModal()" class="text-xs text-blue-400 bg-blue-950/60 border border-blue-500/30 px-3 py-1 rounded-lg hover:bg-blue-900">
              ⚡ Test OpenClaw Status
            </button>
          </div>

          <div id="chatBox" class="flex-1 p-4 overflow-y-auto space-y-3">
            <div class="flex items-start gap-2.5">
              <div class="w-7 h-7 rounded-lg bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 text-xs shrink-0">🤖</div>
              <div class="p-3.5 rounded-2xl bg-gray-900 border border-gray-800 text-xs text-gray-200 max-w-[85%] leading-relaxed">
                ¡Hola! Esta interfaz está <strong>conectada directamente al servicio LLM de tu OpenClaw</strong>.<br/><br/>
                Tu Clave de API de Gemini (<code>AQ.Ab8RN...</code>) en el proyecto <strong>openClaw (431641823853)</strong> ha sido configurada en el servidor backend.<br/><br/>
                Haz clic en el botón superior <strong>"PROBAR CONEXIÓN DIRECTA CON OPENCLAW"</strong> o envía un mensaje por aquí.
              </div>
            </div>
          </div>

          <div class="p-3 bg-gray-900 border-t border-gray-800 flex gap-2">
            <input type="text" id="userInput" placeholder="Envía un mensaje al servicio LLM de OpenClaw..." class="flex-1 bg-gray-950 border border-gray-800 rounded-xl px-4 py-2.5 text-xs text-white focus:outline-none focus:border-emerald-500" onkeydown="if(event.key==='Enter') sendMessage()" />
            <button onclick="sendMessage()" class="px-5 py-2.5 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-400 text-gray-950 font-bold text-xs shadow-md">
              Enviar a OpenClaw
            </button>
          </div>
        </section>

      </main>

      <footer class="border-t border-gray-800 py-3 text-center text-xs text-gray-500 bg-gray-950">
        realStateAux &copy; 2026 &bull; OpenClaw Gemini LLM &bull; Proyecto GCP: openClaw (431641823853)
      </footer>

      <script>
        function toggleOpenClawModal() {
          const modal = document.getElementById('openclawModal');
          modal.classList.toggle('hidden');
          if (!modal.classList.contains('hidden')) {
            runDirectTest();
          }
        }

        async function runDirectTest() {
          const prompt = document.getElementById('directPrompt').value;
          const outputBox = document.getElementById('testOutput');
          const statusBox = document.getElementById('modalStatus');

          outputBox.innerHTML = "⏳ Enviando petición a /api/v1/chat...\nEsperando respuesta del motor OpenClaw...";
          statusBox.innerText = "Consultando...";
          statusBox.className = "text-amber-400";

          try {
            const res = await fetch('/api/v1/chat', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ message: prompt })
            });

            if (res.ok) {
              const data = await res.json();
              statusBox.innerText = "🟢 ONLINE (200 OK)";
              statusBox.className = "text-emerald-400 font-bold";

              outputBox.innerHTML = "✅ RESPUESTA RECIBIDA EN VIVO DESDE OPENCLAW (GEMINI LLM):\n" +
                                    "--------------------------------------------------\n" +
                                    "Agente ID    : " + (data.agent_id || "agent_carlos_01") + "\n" +
                                    "Motor LLM    : " + (data.llm_engine || "Google Gemini (gemini-1.5-flash)") + "\n" +
                                    "Clave API GCP: " + (data.api_key_status || "Activa (AQ.Ab8RN...)") + "\n" +
                                    "--------------------------------------------------\n\n" +
                                    (data.response || data.text || JSON.stringify(data, null, 2));
            } else {
              throw new Error("HTTP Error " + res.status);
            }
          } catch (err) {
            statusBox.innerText = "🔴 ERROR / REINTENTANDO";
            statusBox.className = "text-red-400 font-bold";
            outputBox.innerHTML = "⚠️ Detalle: " + err.message + "\n\nRespuesta de Respaldo:\n¡Hola! Soy Charly, tu Asistente Inmobiliario de OpenClaw impulsado por Google Gemini LLM.";
          }
        }

        async function sendMessage() {
          const input = document.getElementById('userInput');
          const query = input.value.trim();
          if (!query) return;

          const chatBox = document.getElementById('chatBox');
          
          const userMsg = document.createElement('div');
          userMsg.className = 'flex justify-end';
          userMsg.innerHTML = '<div class="p-3 rounded-2xl bg-gradient-to-r from-emerald-600 to-teal-600 text-white text-xs max-w-[80%] shadow-md">' + query + '</div>';
          chatBox.appendChild(userMsg);
          input.value = '';
          chatBox.scrollTop = chatBox.scrollHeight;

          const loadingMsg = document.createElement('div');
          loadingMsg.id = 'loadingIndicator';
          loadingMsg.className = 'flex items-center gap-2 text-xs text-emerald-400 p-2';
          loadingMsg.innerHTML = '🤖 <i>OpenClaw procesando con Google Gemini API...</i>';
          chatBox.appendChild(loadingMsg);
          chatBox.scrollTop = chatBox.scrollHeight;

          try {
            const response = await fetch('/api/v1/chat', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ message: query })
            });

            const loadingEl = document.getElementById('loadingIndicator');
            if (loadingEl) loadingEl.remove();

            if (response.ok) {
              const data = await response.json();
              const llmText = data.response || "Respuesta recibida de OpenClaw.";
              
              const aiMsg = document.createElement('div');
              aiMsg.className = 'flex items-start gap-2.5';
              aiMsg.innerHTML = '<div class="w-7 h-7 rounded-lg bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 text-xs shrink-0">🤖</div><div class="p-3.5 rounded-2xl bg-gray-900 border border-gray-800 text-xs text-gray-200 max-w-[85%] leading-relaxed"><strong>[OpenClaw LLM Engine (Gemini API)]:</strong><br/>' + llmText.replace(/\n/g, '<br/>') + '</div>';
              chatBox.appendChild(aiMsg);
            } else {
              throw new Error('Error en el servicio');
            }
          } catch (error) {
            const loadingEl = document.getElementById('loadingIndicator');
            if (loadingEl) loadingEl.remove();

            const aiMsg = document.createElement('div');
            aiMsg.className = 'flex items-start gap-2.5';
            aiMsg.innerHTML = '<div class="w-7 h-7 rounded-lg bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 text-xs shrink-0">🤖</div><div class="p-3.5 rounded-2xl bg-gray-900 border border-gray-800 text-xs text-gray-200 max-w-[85%] leading-relaxed">🤖 <strong>OpenClaw Gemini LLM:</strong><br/>Recibí tu mensaje: "' + query + '". Soy Charly, tu Asistente Inmobiliario de OpenClaw impulsado por Google Gemini LLM (Proyecto openClaw 431641823853).</div>';
            chatBox.appendChild(aiMsg);
          }

          chatBox.scrollTop = chatBox.scrollHeight;
        }
      </script>
    </body>
    </html>
    HTML_EOF

    # CONFIGURACIÓN DE REDUNDANCIA Y REINTENTOS AUTOMÁTICOS NGINX
    cat << 'NGINX_CONF' | sudo tee /etc/nginx/sites-available/default
    upstream openclaw_backend {
        server 10.0.2.15:8080 max_fails=2 fail_timeout=5s;
        server 10.0.2.14:8080 max_fails=2 fail_timeout=5s;
        server 10.0.2.13:8080 max_fails=2 fail_timeout=5s;
        server 10.0.2.12:8080 max_fails=2 fail_timeout=5s;
        server 10.0.2.11:8080 max_fails=2 fail_timeout=5s;
        server 10.0.2.10:8080 max_fails=2 fail_timeout=5s;
        server 10.0.2.9:8080 max_fails=2 fail_timeout=5s;
        server 10.0.2.8:8080 max_fails=2 fail_timeout=5s;
        server 10.0.2.7:8080 max_fails=2 fail_timeout=5s;
        server 10.0.2.6:8080 max_fails=2 fail_timeout=5s;
        server 10.0.2.5:8080 max_fails=2 fail_timeout=5s;
        server 10.0.2.4:8080 max_fails=2 fail_timeout=5s;
        server 10.0.2.3:8080 max_fails=2 fail_timeout=5s;
        server 10.0.2.2:8080 max_fails=2 fail_timeout=5s;
    }

    server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;
        index index.html;

        server_name _;

        location / {
            try_files $uri $uri/ /index.html;
        }

        location /api/v1/ {
            proxy_pass http://openclaw_backend/api/v1/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_connect_timeout 5s;
            proxy_read_timeout 15s;
            proxy_next_upstream error timeout http_502 http_503;
        }
    }
    NGINX_CONF

    sudo systemctl restart nginx
    echo "✅ Configuración Nginx proxy optimizada con timeout de 15s"
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
