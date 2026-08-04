# realStateAux - Asistente Inmobiliario Autónomo (OpenClaw + GCP)

Plataforma de **Asistente Inmobiliario Autónomo** multi-usuario con arquitectura aislada, optimización extrema de costos en **Google Cloud Platform (GCP)** y motor de agentes inteligente **OpenClaw**.

---

## 🎯 Descripción del Proyecto

El sistema está diseñado para que corredores y agencias inmobiliarias cuenten con un asistente de IA dedicado denominado **"Charly"**, capaz de atender clientes 24/7 vía WhatsApp Business o Telegram Bot API, calificar leads, consultar el inventario de propiedades y agendar visitas presenciales.

---

## 📁 Estructura del Repositorio (`Feature2IAEngine`)

```
.
├── README.md                          # Guía principal del proyecto
├── data/                              # Requisitos de Datos Dummy para Entorno de Pruebas
│   ├── properties_dummy.json          # Inventario de propiedades de prueba (Casas / Aptos)
│   ├── calendar_mock.json             # Simulador de disponibilidad de agenda del agente
│   ├── faq_inmobiliaria.md            # Base de conocimiento y políticas de atención
│   └── leads_synthetic.json           # Perfiles sintéticos de leads (WhatsApp / Telegram)
├── api/                               # API REST Ligera (FastAPI - Python)
│   ├── app/                           # Endpoints (/properties, /calendar, /faq, /leads)
│   ├── requirements.txt               # Dependencias Python ultraligeras
│   ├── Dockerfile                     # Construcción Docker optimizada para e2-micro
│   └── test_api.py                    # Suite de pruebas automatizadas
├── agent_engine/                      # Orquestador SRE y Motor de Agentes OpenClaw
│   ├── app/                           # API Admin (/admin/provision, /admin/instances)
│   │   ├── main.py                    # Admin Panel Backend API
│   │   ├── provisioner.py             # Docker Container Orchestrator (256MB RAM / 0.5 CPU)
│   │   ├── crypto.py                  # Cifrado Fernet/AES-256 de credenciales de usuario
│   │   ├── config.py                  # Parámetros SRE y gestión de recursos
│   │   └── models.py                  # Esquemas Pydantic
│   ├── mock_openclaw/                 # Runtime simulado de OpenClaw Agent
│   │   ├── app.py                     # Ciclo persistente 24/7 consumiendo Data API
│   │   └── Dockerfile                 # Contenedor ultra ligero Alpine (<20MB)
│   ├── test_provisioning.py           # Pruebas end-to-end de aprovisionamiento
│   └── README.md                      # Manual SRE de contenedores y cifrado
└── terraform/                         # Infraestructura como Código en GCP
    ├── main.tf                        # Orquestación de módulos de infraestructura
    ├── variables.tf                   # Variables globales de Terraform
    ├── outputs.tf                     # Salidas y resumen de optimización de costos
    └── README.md                      # Manual detallado de despliegue y arquitectura GCP
```

---

## 🤖 Motor de Agentes y Orquestación SRE (`/agent_engine`)

- **Aprovisionamiento Dinámico Multi-usuario**: Generación automática de contenedores aislados de OpenClaw por cada nuevo correo de usuario.
- **Cifrado de Credenciales**: Cifrado simétrico AES-256 para tokens de WhatsApp, Telegram y LLM API Keys.
- **Límites Estrictos de Recursos**: Máximo `256MB` RAM y `0.5` vCPU por contenedor para evitar sobrecostos en `e2-micro`.

Para más detalles técnicos, consulta el **[README del Orquestador SRE](file:///home/joanr/agentic-platforms/GCP/realStateAux/agent_engine/README.md)**.
