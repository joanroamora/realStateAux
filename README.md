# realStateAux - Asistente Inmobiliario Autónomo (OpenClaw + GCP)

Plataforma de **Asistente Inmobiliario Autónomo** multi-usuario con arquitectura aislada, optimización extrema de costos en **Google Cloud Platform (GCP)** y motor de agentes inteligente **OpenClaw**.

---

## 🎯 Descripción del Proyecto

El sistema está diseñado para que corredores y agencias inmobiliarias cuenten con un asistente de IA dedicado denominado **"Charly"**, capaz de atender clientes 24/7 vía WhatsApp Business o Telegram Bot API, calificar leads, consultar el inventario de propiedades y agendar visitas presenciales.

---

## 📁 Estructura del Repositorio (`Feature3Gui` + SRE CI/CD)

```
.
├── README.md                          # Guía principal del proyecto
├── .github/
│   └── workflows/
│       ├── ci-cd.yml                  # Pipeline CI/CD + Publicación en GitHub Packages (GHCR)
│       └── infra-destroy.yml          # Destrucción segura y purga con cerradura de seguridad
├── data/                              # Requisitos de Datos Dummy para Entorno de Pruebas
│   ├── properties_dummy.json          # Inventario de propiedades de prueba (Casas / Aptos)
│   ├── calendar_mock.json             # Simulador de disponibilidad de agenda del agente
│   ├── faq_inmobiliaria.md            # Base de conocimiento y políticas de atención
│   └── leads_synthetic.json           # Perfiles sintéticos de leads (WhatsApp / Telegram)
├── frontend/                          # Interfaz Web UI/UX (React.js + Tailwind CSS)
│   ├── src/                           # Componentes (Navbar, FeatureGrid, ChatCharly, AdminModal)
│   └── package.json                   # React 19, Lucide Icons & Tailwind v4
├── api/                               # API REST Ligera (FastAPI - Python)
│   ├── app/                           # Endpoints (/properties, /calendar, /faq, /leads)
│   ├── requirements.txt               # Dependencias Python ultraligeras
│   └── Dockerfile                     # Construcción Docker optimizada para e2-micro
├── agent_engine/                      # Orquestador SRE y Motor de Agentes OpenClaw
│   ├── app/                           # API Admin (/admin/provision, /admin/instances)
│   └── mock_openclaw/                 # Runtime simulado de OpenClaw Agent
└── terraform/                         # Infraestructura como Código en GCP
    ├── main.tf                        # Orquestación de módulos de infraestructura
    ├── destroy_infrastructure.sh      # Script de destrucción automatizada y purga GCP
    ├── verify_zero_trace.py           # Auditoría de Certificación de Cero Rastro (0 gastos)
    └── README.md                      # Manual detallado de despliegue y arquitectura GCP
```

---

## ⚙️ CI/CD y GitHub Packages (GHCR)

El flujo de integración y despliegue continuo automatizado en [`.github/workflows/ci-cd.yml`](file:///home/joanr/agentic-platforms/GCP/realStateAux/.github/workflows/ci-cd.yml) ejecuta:

1. **Pruebas de la API de Datos**: Pruebas automáticas de la API REST en FastAPI.
2. **Pruebas del Orquestador SRE**: Validación de cifrado Fernet/AES-256 y cuotas de contenedores OpenClaw.
3. **Build del Frontend**: Compilación de producción con Vite + React + Tailwind CSS.
4. **Validación de Terraform**: `terraform fmt -check` y `terraform validate`.
5. **Publicación en GHCR (`ghcr.io`)**:
   - `ghcr.io/joanroamora/realstateaux-api:latest`
   - `ghcr.io/joanroamora/realstateaux-openclaw:latest`

---

## 🛡️ Sistema de Aseguramiento de Eliminación de Todo Rastro (Cero Rastro GCP)

Para evitar cobros recurrentes o recursos huérfanos tras finalizar pruebas:

### 1. Eliminación Local / CLI
```bash
cd terraform
bash destroy_infrastructure.sh
```
El script ejecuta `terraform destroy`, elimina reglas de firewall remanentes, subredes, VPC e invoca la auditoría [`verify_zero_trace.py`](file:///home/joanr/agentic-platforms/GCP/realStateAux/terraform/verify_zero_trace.py).

### 2. Eliminación vía GitHub Actions Workflow
Usa la acción [`.github/workflows/infra-destroy.yml`](file:///home/joanr/agentic-platforms/GCP/realStateAux/.github/workflows/infra-destroy.yml) mediante `workflow_dispatch` ingresando el token de confirmación `DELETE_ALL`.

### 3. Matriz de Auditoría Cero Rastro
```
=================================================================
 🛡️  AUDITORÍA DE SEGURIDAD SRE: CERTIFICACIÓN DE CERO RASTRO GCP
=================================================================
  ✅ Instancias Compute Engine (VMs)       : 0 (CERO RASTRO)
  ✅ Discos Persistentes Huérfanos         : 0 (CERO RASTRO)
  ✅ Reglas de Firewall Personalizadas     : 0 (CERO RASTRO)
  ✅ Subredes VPC Personalizadas           : 0 (CERO RASTRO)
  ✅ VPC Principal                         : 0 (CERO RASTRO)
-----------------------------------------------------------------
  🎉 CERTIFICADO DE CERO RASTRO: APROBADO
```
