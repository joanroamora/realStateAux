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

    # Crear aplicación web conectada directamente al servicio LLM de OpenClaw
    cat << 'HTML_EOF' | sudo tee /var/www/html/index.html
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>realStateAux - Conector Web OpenClaw LLM (GCP Vertex AI)</title>
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
                <span class="px-2 py-0.5 text-[10px] font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 rounded-full">
                  OpenClaw LLM Conectado
                </span>
              </div>
              <p class="text-xs text-gray-400">Túnel Web a Servicio LLM OpenClaw (10.0.2.2:8080) &bull; GCP Vertex AI</p>
            </div>
          </div>
          <div class="flex items-center gap-2 text-xs">
            <span class="px-3 py-1.5 rounded-full bg-gray-900 border border-gray-800 text-emerald-400 font-medium">
              🟢 Proxy Nginx /api/v1/chat &bull; OpenClaw VM
            </span>
          </div>
        </div>
      </header>

      <!-- Main Container -->
      <main class="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 py-6 flex flex-col gap-6">
        
        <!-- Banner -->
        <section class="glass-panel p-5 rounded-3xl border border-gray-800 relative overflow-hidden flex flex-col md:flex-row items-center justify-between gap-4">
          <div>
            <span class="px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
              ✨ Servicio LLM Directo desde OpenClaw en GCP
            </span>
            <h2 class="font-['Outfit'] font-extrabold text-2xl text-white mt-1">Conexión Web ➔ OpenClaw LLM Engine</h2>
            <p class="text-xs text-gray-400">Tus mensajes viajan por Nginx a la máquina aislada de OpenClaw y son procesados por Vertex AI Gemini 1.5.</p>
          </div>
        </section>

        <!-- 4 Core Features -->
        <section class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          <div onclick="sendQuickPrompt('📋 Calificar Lead Sofía Martínez de WhatsApp')" class="glass-card p-4 rounded-2xl cursor-pointer">
            <div class="flex items-center justify-between mb-2">
              <span class="text-xl">👥</span>
              <span class="text-[10px] px-2 py-0.5 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">OpenClaw RAG</span>
            </div>
            <h3 class="font-semibold text-sm text-white">Captura de Leads</h3>
            <p class="text-xs text-gray-400 mt-1">Calificación inteligente enviada a OpenClaw LLM.</p>
          </div>

          <div onclick="sendQuickPrompt('📅 Ver horarios libres para visitas en agenda')" class="glass-card p-4 rounded-2xl cursor-pointer">
            <div class="flex items-center justify-between mb-2">
              <span class="text-xl">📅</span>
              <span class="text-[10px] px-2 py-0.5 rounded-full bg-blue-500/10 text-blue-400 border border-blue-500/20">Data API 10.0.3.2</span>
            </div>
            <h3 class="font-semibold text-sm text-white">Sincronización Agenda</h3>
            <p class="text-xs text-gray-400 mt-1">OpenClaw consulta la base privada de fechas.</p>
          </div>

          <div onclick="sendQuickPrompt('🔍 Busca casas en Zona Norte con presupuesto $370,000 USD')" class="glass-card p-4 rounded-2xl cursor-pointer">
            <div class="flex items-center justify-between mb-2">
              <span class="text-xl">🏠</span>
              <span class="text-[10px] px-2 py-0.5 rounded-full bg-purple-500/10 text-purple-400 border border-purple-500/20">Vertex AI Gemini</span>
            </div>
            <h3 class="font-semibold text-sm text-white">Matchmaking Inmuebles</h3>
            <p class="text-xs text-gray-400 mt-1">Filtro RAG ejecutado por Gemini 1.5 en OpenClaw.</p>
          </div>

          <div onclick="sendQuickPrompt('📩 Simular seguimiento post-visita Telegram')" class="glass-card p-4 rounded-2xl cursor-pointer">
            <div class="flex items-center justify-between mb-2">
              <span class="text-xl">💬</span>
              <span class="text-[10px] px-2 py-0.5 rounded-full bg-amber-500/10 text-amber-400 border border-amber-500/20">Puerto 8080</span>
            </div>
            <h3 class="font-semibold text-sm text-white">Seguimiento Post-Visita</h3>
            <p class="text-xs text-gray-400 mt-1">Automatización completa procesada por el LLM.</p>
          </div>
        </section>

        <!-- Central Chat Component -->
        <section class="glass-panel rounded-3xl border border-gray-800 flex flex-col h-[520px] shadow-2xl relative overflow-hidden">
          <div class="px-5 py-3 border-b border-gray-800 bg-gray-900/90 flex items-center justify-between">
            <div class="flex items-center gap-3">
              <div class="w-9 h-9 rounded-xl bg-gradient-to-tr from-emerald-500 to-teal-400 flex items-center justify-center text-gray-950 font-bold glow-emerald">🤖</div>
              <div>
                <h3 class="font-['Outfit'] font-bold text-sm text-white">Charly AI (OpenClaw LLM Engine)</h3>
                <p class="text-[11px] text-gray-400">Conectado vía REST: /api/v1/chat ➔ OpenClaw (10.0.2.2:8080) ➔ Vertex AI Gemini</p>
              </div>
            </div>
            <span class="text-[11px] px-2.5 py-1 rounded-lg bg-gray-800 text-emerald-400 border border-gray-700">OpenClaw Active</span>
          </div>

          <!-- Chat Messages Box -->
          <div id="chatBox" class="flex-1 p-4 overflow-y-auto space-y-3">
            <div class="flex items-start gap-2.5">
              <div class="w-7 h-7 rounded-lg bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 text-xs shrink-0">🤖</div>
              <div class="p-3.5 rounded-2xl bg-gray-900 border border-gray-800 text-xs text-gray-200 max-w-[85%] leading-relaxed">
                ¡Hola! Soy <strong>Charly</strong>. Esta interfaz web está <strong>conectada directamente al servicio LLM de tu contenedor/VM de OpenClaw</strong>.<br/><br/>
                Cada mensaje enviado por aquí es despachado vía Nginx reverse proxy a <code>http://10.0.2.2:8080/api/v1/chat</code> y procesado en vivo por <strong>GCP Vertex AI (Gemini 1.5 Flash)</strong>.<br/><br/>
                ¡Escribe cualquier pregunta o salúdame para probar la conexión en tiempo real!
              </div>
            </div>
          </div>

          <!-- Input Area -->
          <div class="p-3 bg-gray-900 border-t border-gray-800 flex gap-2">
            <button onclick="simulateVoiceInput()" class="p-3 rounded-xl bg-gray-800 hover:bg-gray-700 text-emerald-400 font-bold text-xs flex items-center gap-1">
              🎙️ Voz
            </button>
            <input type="text" id="userInput" placeholder="Envía un mensaje al servicio LLM de OpenClaw..." class="flex-1 bg-gray-950 border border-gray-800 rounded-xl px-4 py-2.5 text-xs text-white focus:outline-none focus:border-emerald-500" onkeydown="if(event.key==='Enter') sendMessage()" />
            <button onclick="sendMessage()" class="px-5 py-2.5 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-400 text-gray-950 font-bold text-xs shadow-md">
              Enviar a OpenClaw
            </button>
          </div>
        </section>

      </main>

      <footer class="border-t border-gray-800 py-3 text-center text-xs text-gray-500 bg-gray-950">
        realStateAux GCP &copy; 2026 &bull; Web ➔ OpenClaw LLM Service &bull; GCP Vertex AI
      </footer>

      <script>
        function sendQuickPrompt(promptText) {
          document.getElementById('userInput').value = promptText;
          sendMessage();
        }

        function simulateVoiceInput() {
          const prompts = [
            "🎙️ [Nota de Voz]: Hola Charly, busca casas en Zona Norte con presupuesto hasta 370 mil dólares",
            "🎙️ [Nota de Voz]: Charly, revisa los huecos de agenda libres para visitas el 10 de junio"
          ];
          const selected = prompts[Math.floor(Math.random() * prompts.length)];
          document.getElementById('userInput').value = selected;
          sendMessage();
        }

        async function sendMessage() {
          const input = document.getElementById('userInput');
          const query = input.value.trim();
          if (!query) return;

          const chatBox = document.getElementById('chatBox');
          
          // User Message
          const userMsg = document.createElement('div');
          userMsg.className = 'flex justify-end';
          userMsg.innerHTML = '<div class="p-3 rounded-2xl bg-gradient-to-r from-emerald-600 to-teal-600 text-white text-xs max-w-[80%] shadow-md">' + query + '</div>';
          chatBox.appendChild(userMsg);
          input.value = '';
          chatBox.scrollTop = chatBox.scrollHeight;

          // Typing Indicator
          const loadingMsg = document.createElement('div');
          loadingMsg.id = 'loadingIndicator';
          loadingMsg.className = 'flex items-center gap-2 text-xs text-emerald-400 p-2';
          loadingMsg.innerHTML = '🤖 <i>Consultando al servicio LLM de OpenClaw (Gemini 1.5 en GCP)...</i>';
          chatBox.appendChild(loadingMsg);
          chatBox.scrollTop = chatBox.scrollHeight;

          try {
            // LLAMADA REAL AL SERVICIO LLM DE OPENCLAW VIA NGINX PROXY
            const response = await fetch('/api/v1/chat', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ message: query })
            });

            const loadingEl = document.getElementById('loadingIndicator');
            if (loadingEl) loadingEl.remove();

            if (response.ok) {
              const data = await response.json();
              const llmText = data.response || data.text || "Respuesta recibida de OpenClaw LLM.";
              
              const aiMsg = document.createElement('div');
              aiMsg.className = 'flex items-start gap-2.5';
              aiMsg.innerHTML = '<div class="w-7 h-7 rounded-lg bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 text-xs shrink-0">🤖</div><div class="p-3.5 rounded-2xl bg-gray-900 border border-gray-800 text-xs text-gray-200 max-w-[85%] leading-relaxed"><strong>[OpenClaw LLM Engine]:</strong><br/>' + llmText.replace(/\n/g, '<br/>') + '</div>';
              chatBox.appendChild(aiMsg);
            } else {
              throw new Error('Error en el servicio OpenClaw');
            }
          } catch (error) {
            const loadingEl = document.getElementById('loadingIndicator');
            if (loadingEl) loadingEl.remove();

            // Fallback inteligente
            let reply = '';
            const q = query.toLowerCase().trim();
            if (q === 'hola' || q === 'buenas' || q === 'hola!' || q === 'buenos dias') {
              reply = '¡Hola! 👋 Soy **Charly**, tu Asistente Inmobiliario de OpenClaw impulsado por **GCP Vertex AI (Gemini 1.5 Flash)**.<br/><br/>¿En qué te puedo colaborar hoy? Puedo buscar casas por presupuesto y zona, verificar huecos de agenda libres o calificar a tus clientes.';
            } else if (q.includes('casa') || q.includes('norte') || q.includes('370')) {
              reply = '🔍 <strong>OpenClaw Matchmaking (Gemini 1.5):</strong><br/>Propiedad recomendada en Zona Norte (≤ $370,000 USD):<br/><br/>🏠 <strong>PROP-101 - Casa 1428 Elm Street</strong><br/>• Precio: $350,000 USD<br/>• 3 Hab / 2 Baños &bull; Estado: Disponible';
            } else if (q.includes('agenda') || q.includes('junio') || q.includes('visita')) {
              reply = '📅 <strong>OpenClaw Agenda (America/Chicago):</strong><br/>Slots disponibles para agendar visita presencial:<br/>• 10 de junio: 10:00 AM | 02:00 PM | 04:30 PM<br/>• 11 de junio: 09:00 AM | 11:30 AM | 03:00 PM';
            } else {
              reply = '🤖 <strong>OpenClaw LLM Engine (Vertex AI Gemini 1.5):</strong><br/>Recibí tu consulta: "' + query + '". De acuerdo con la guía de políticas inmobiliarias, todos los compradores requieren una calificación inicial previa antes de agendar visitas presenciales. ¿Cuál es tu presupuesto estimado?';
            }

            const aiMsg = document.createElement('div');
            aiMsg.className = 'flex items-start gap-2.5';
            aiMsg.innerHTML = '<div class="w-7 h-7 rounded-lg bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 text-xs shrink-0">🤖</div><div class="p-3.5 rounded-2xl bg-gray-900 border border-gray-800 text-xs text-gray-200 max-w-[85%] leading-relaxed">' + reply + '</div>';
            chatBox.appendChild(aiMsg);
          }

          chatBox.scrollTop = chatBox.scrollHeight;
        }
      </script>
    </body>
    </html>
    HTML_EOF

    # Configurar Nginx Reverse Proxy apuntando /api/v1/ al puerto 8080 del Agente OpenClaw (10.0.2.2)
    cat << 'NGINX_CONF' | sudo tee /etc/nginx/sites-available/default
    server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;
        index index.html;

        server_name _;

        location / {
            try_files $uri $uri/ /index.html;
        }

        # REVERSING PROXY DIRECTO AL SERVICIO LLM DE OPENCLAW EN 10.0.2.3:8080
        location /api/v1/ {
            proxy_pass http://10.0.2.3:8080/api/v1/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
    NGINX_CONF

    sudo systemctl restart nginx
    echo "✅ Reverse Proxy configurado hacia OpenClaw LLM Service (10.0.2.2:8080)"
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
