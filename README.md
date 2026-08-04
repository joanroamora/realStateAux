# realStateAux - Asistente Inmobiliario Autónomo (OpenClaw + GCP)

Plataforma de **Asistente Inmobiliario Autónomo** multi-usuario con arquitectura aislada, optimización extrema de costos en **Google Cloud Platform (GCP)** y motor de agentes inteligente **OpenClaw**.

---

## 🎯 Descripción del Proyecto

El sistema está diseñado para que corredores y agencias inmobiliarias cuenten con un asistente de IA dedicado denominado **"Charly"**, capaz de atender clientes 24/7 vía WhatsApp Business o Telegram Bot API, calificar leads, consultar el inventario de propiedades y agendar visitas presenciales.

---

## 📁 Estructura del Repositorio

```
.
├── README.md                          # Guía principal del proyecto
├── data/                              # Requisitos de Datos Dummy para Entorno de Pruebas
│   ├── properties_dummy.json          # Inventario de propiedades de prueba (Casas / Aptos)
│   ├── calendar_mock.json             # Simulador de disponibilidad de agenda del agente
│   ├── faq_inmobiliaria.md            # Base de conocimiento y políticas de atención
│   └── leads_synthetic.json           # Perfiles sintéticos de leads (WhatsApp / Telegram)
├── api/                               # API REST Ligera (FastAPI - Python)
│   ├── app/                           # Código fuente (main.py, auth.py, config.py)
│   ├── requirements.txt               # Dependencias Python ultraligeras
│   ├── Dockerfile                     # Construcción Docker optimizada para e2-micro
│   ├── test_api.py                    # Suite de pruebas automatizadas
│   └── README.md                      # Documentación detallada de endpoints y uso de Docker
└── terraform/                         # Infraestructura como Código en GCP
    ├── main.tf                        # Orquestación de módulos de infraestructura
    ├── variables.tf                   # Variables globales de Terraform
    ├── outputs.tf                     # Salidas y resumen de optimización de costos
    ├── terraform.tfvars.example       # Plantilla de variables de entorno
    ├── README.md                      # Manual detallado de despliegue y arquitectura GCP
    └── modules/                       # Módulos reutilizables de Terraform
        ├── vpc/                       # Red personalizada con subredes aisladas
        ├── firewall/                  # Reglas estrictas de seguridad e inyección
        ├── database/                  # Base de datos e2-micro en subred privada
        └── agent_backend/             # Entornos de agentes OpenClaw aislados 24/7
```

---

## 🚀 Servicios Backend (`/api`)

La API REST en **FastAPI** sirve los datos dummy de solo lectura con protección por token (`X-API-Token`) y consumo reducido (<40MB RAM):

- **[`GET /health`](file:///home/joanr/agentic-platforms/GCP/realStateAux/api/README.md)**: Monitoreo de salud.
- **[`GET /api/v1/properties`](file:///home/joanr/agentic-platforms/GCP/realStateAux/api/README.md)**: Inventario de propiedades.
- **[`GET /api/v1/calendar`](file:///home/joanr/agentic-platforms/GCP/realStateAux/api/README.md)**: Disponibilidad de agendamiento.
- **[`GET /api/v1/faq`](file:///home/joanr/agentic-platforms/GCP/realStateAux/api/README.md)**: FAQ y políticas (Markdown).
- **[`GET /api/v1/leads`](file:///home/joanr/agentic-platforms/GCP/realStateAux/api/README.md)**: Leads sintéticos para simulación.

---

## ☁️ Infraestructura GCP con Terraform (`/terraform`)

- **Subred Pública Frontend**: Hospeda el proxy inverso/interfaz web pública.
- **Subred Protegida Backend**: Instancias `e2-micro` aisladas de Internet para OpenClaw.
- **Subred Privada Datos**: Instancia de datos `e2-micro` accesible exclusivamente desde el frontend autorizado.
- **Acceso Administrativo**: Conexiones SSH seguras vía **GCP IAP (Identity-Aware Proxy)**.

Para más información, consulta el **[README de Terraform](file:///home/joanr/agentic-platforms/GCP/realStateAux/terraform/README.md)** y el **[README de la API](file:///home/joanr/agentic-platforms/GCP/realStateAux/api/README.md)**.
