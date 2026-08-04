# realStateAux - Asistente Inmobiliario Autónomo (OpenClaw + GCP)

Plataforma de **Asistente Inmobiliario Autónomo** multi-usuario con arquitectura aislada, optimización extrema de costos en **Google Cloud Platform (GCP)** y motor de agentes inteligente **OpenClaw**.

---

## 🎯 Descripción del Proyecto

El sistema está diseñado para que corredores y agencias inmobiliarias cuenten con un asistente de IA dedicado denominado **"Charly"**, capaz de atender clientes 24/7 vía WhatsApp Business o Telegram Bot API, calificar leads, consultar el inventario de propiedades y agendar visitas presenciales.

---

## 📁 Estructura del Repositorio (`Feature3Gui`)

```
.
├── README.md                          # Guía principal del proyecto
├── data/                              # Requisitos de Datos Dummy para Entorno de Pruebas
│   ├── properties_dummy.json          # Inventario de propiedades de prueba (Casas / Aptos)
│   ├── calendar_mock.json             # Simulador de disponibilidad de agenda del agente
│   ├── faq_inmobiliaria.md            # Base de conocimiento y políticas de atención
│   └── leads_synthetic.json           # Perfiles sintéticos de leads (WhatsApp / Telegram)
├── frontend/                          # Interfaz Web UI/UX (React.js + Tailwind CSS)
│   ├── src/
│   │   ├── components/
│   │   │   ├── Navbar.jsx             # Barra superior con estado de red VPC aislada
│   │   │   ├── FeatureGrid.jsx        # Tarjetas interactivas de las 4 tareas automáticas
│   │   │   ├── ChatCharly.jsx         # Chat central con Charly AI (Texto, Voz & Chips)
│   │   │   ├── AdminModal.jsx         # Panel de alta de usuarios y aprovisionamiento SRE
│   │   │   └── DataExplorerModal.jsx  # Visualizador de datos JSON/MD privados
│   │   ├── App.jsx                    # Layout principal y coordinación de modales
│   │   └── index.css                  # Estilos glassmorphism y sistema de diseño
│   ├── package.json                   # React 19, Lucide Icons & Tailwind v4
│   └── vite.config.js                 # Configuración de empaquetado optimizado
├── api/                               # API REST Ligera (FastAPI - Python)
│   ├── app/                           # Endpoints (/properties, /calendar, /faq, /leads)
│   ├── requirements.txt               # Dependencias Python ultraligeras
│   └── Dockerfile                     # Construcción Docker optimizada para e2-micro
├── agent_engine/                      # Orquestador SRE y Motor de Agentes OpenClaw
│   ├── app/                           # API Admin (/admin/provision, /admin/instances)
│   └── mock_openclaw/                 # Runtime simulado de OpenClaw Agent
└── terraform/                         # Infraestructura como Código en GCP
    └── README.md                      # Manual detallado de despliegue y arquitectura GCP
```

---

## 🖥️ Interfaz de Usuario y Panel de Administración (`/frontend`)

- **Diseño Responsivo (Mobile-First & Desktop)**: Interfaz minimalista con estética moderna (*glassmorphism*, degradados suaves y tipografía *Inter/Outfit*).
- **Las 4 Funcionalidades Automatizadas Destacadas**:
  1. *Captura de Leads* (WhatsApp / Telegram API).
  2. *Sincronización de Agenda* (America/Chicago sin traslapes).
  3. *Matchmaking de Propiedades* (Filtro por presupuesto y zona).
  4. *Seguimiento Post-Visita* (Fidelización automatizada).
- **Chat Interactivo con "Charly"**: Soporta entrada/salida de **texto**, comandos por **voz con indicador de onda de audio**, chips de acciones rápidas y renderizado interactivo de propiedades y slots.
- **Panel de Administración Central**: Alta de nuevos usuarios y simulación de aprovisionamiento de contenedores en subred aislada de GCP.

---

## 🚀 Guía de Ejecución Local de la Interfaz

```bash
cd frontend
npm install
npm run dev
```

Navega a `http://localhost:5173` para interactuar con la aplicación web.
