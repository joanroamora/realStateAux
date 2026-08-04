# realStateAux - Asistente Inmobiliario Autónomo (OpenClaw + GCP)

Plataforma de **Asistente Inmobiliario Autónomo** multi-usuario con arquitectura aislada, optimización extrema de costos en **Google Cloud Platform (GCP)** y motor de agentes inteligente **OpenClaw**.

---

## 🎯 Descripción del Proyecto

El sistema está diseñado para que corredores e agencias inmobiliarias cuenten con un asistente de IA dedicado denominado **"Charly"**, capaz de atender clientes 24/7 vía WhatsApp Business o Telegram Bot API, calificar leads, consultar el inventario de propiedades y agendar visitas presenciales.

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

## 💾 Datos Dummy de Pruebas (`/data`)

Los datos iniciales de prueba están configurados en la carpeta [`/data`](file:///home/joanr/agentic-platforms/GCP/realStateAux/data):

- **[properties_dummy.json](file:///home/joanr/agentic-platforms/GCP/realStateAux/data/properties_dummy.json)**: Propiedades en zonas Norte, Oeste y Costera.
- **[calendar_mock.json](file:///home/joanr/agentic-platforms/GCP/realStateAux/data/calendar_mock.json)**: Disponibilidad de agenda para agendamiento de visitas.
- **[faq_inmobiliaria.md](file:///home/joanr/agentic-platforms/GCP/realStateAux/data/faq_inmobiliaria.md)**: Reglas de negocio (calificación previa, confidencialidad, comisiones).
- **[leads_synthetic.json](file:///home/joanr/agentic-platforms/GCP/realStateAux/data/leads_synthetic.json)**: Ejemplos de leads entrantes por WhatsApp y Telegram.

---

## ☁️ Infraestructura GCP con Terraform (`/terraform`)

La infraestructura sigue una política de **Ahorro Extremo de Costos** y **Aislamiento Multi-usuario**:

- **Subred Pública Frontend**: Hospeda el proxy inverso/interfaz web pública.
- **Subred Protegida Backend**: Instancias `e2-micro` aisladas de Internet para OpenClaw.
- **Subred Privada Datos**: Instancia de datos `e2-micro` accesible exclusivamente desde el frontend autorizado.
- **Acceso Administrativo**: Conexiones SSH seguras vía **GCP IAP (Identity-Aware Proxy)** sin IPs públicas expuestas.

Para más información y comandos de despliegue, consulta el **[README de Terraform](file:///home/joanr/agentic-platforms/GCP/realStateAux/terraform/README.md)**.
