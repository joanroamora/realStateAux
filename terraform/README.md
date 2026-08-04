# Infraestructura como Código (Terraform) - Asistente Inmobiliario Autónomo (OpenClaw + GCP)

Este módulo contiene la configuración de **Terraform** para desplegar la arquitectura base de bajo costo en **Google Cloud Platform (GCP)** para el sistema de Asistentes Inmobiliarios Autónomos basados en **OpenClaw**.

---

## 🏗️ Arquitectura de Red y Seguridad

La infraestructura está diseñada bajo el principio de **Aislamiento por Capas y Mínimo Privilegio**:

```
                      +---------------------------------------+
                      |         INTERNET PÚBLICO             |
                      +---------------------------------------+
                                          |
                                          v (HTTP/HTTPS: 80, 443, 3000)
                     +-----------------------------------------+
                     |       Subred Frontend Pública          |
                     |       (IP Pública / Reverse Proxy)      |
                     +-----------------------------------------+
                                 |                 |
     (Port 8080 - Tráfico interno) |                 | (Port 5432 - DB Privada)
                                 v                 v
           +---------------------------+   +---------------------------+
           | Subred Protegida Backend  |   |   Subred Privada Datos    |
           | Instancias OpenClaw       |   |   DB Instancia (e2-micro) |
           | (Sin IP Pública Externa)  |   | (Sin IP Pública Externa)  |
           +---------------------------+   +---------------------------+
```

---

## 🛠️ Estructura de Módulos

```
terraform/
├── main.tf                 # Configuración principal y orquestación de módulos
├── variables.tf            # Variables globales del proyecto
├── outputs.tf              # Salidas de infraestructura y desglose de costos
├── terraform.tfvars.example# Plantilla de valores de variables
└── modules/
    ├── vpc/                # VPC personalizada con 3 subredes aisladas y Cloud NAT
    ├── firewall/           # Reglas estrictas de firewall para prevenir inyecciones
    ├── database/           # Instancia e2-micro de base de datos en capa privada
    └── agent_backend/      # Instancias e2-micro aisladas para agentes multi-usuario
```

---

## 💰 Estrategias de Minimización Extrema de Costos

1. **Uso de Instancias `e2-micro`**:
   - Tanto la base de datos como los backends de OpenClaw utilizan el tipo de máquina `e2-micro` (2 vCPU compartidas, 1 GB RAM).
   - En GCP, la primera instancia `e2-micro` en ciertas regiones (`us-central1`, `us-east1`, `us-west1`) califica dentro de la **Capa Gratuita (Free Tier)**.

2. **Sin IPs Públicas Innecesarias**:
   - Las instancias de Base de Datos y de Agentes OpenClaw **no poseen dirección IP pública**. Esto ahorra aproximadamente **$3.60 USD/mes por dirección IP pública no utilizada** y elimina la superficie de ataque desde Internet.

3. **Acceso Administrativo SSH sin Costo con GCP IAP**:
   - En lugar de mantener una máquina Bastion encendida 24/7, el acceso SSH se realiza mediante **Google Cloud Identity-Aware Proxy (IAP)**, permitiendo tunelizar SSH por `gcloud` de forma gratuita y segura.

4. **Almacenamiento Mínimo Eficiente (`pd-standard`)**:
   - Se utiliza `pd-standard` (Disco Estándar) de 10 GB por instancia, manteniendo el costo de almacenamiento por debajo de **~$0.40 USD/mes por disco**.

5. **Estimación Mensual Aproximada por Usuario**:
   - **DB Server**: ~$0.00 USD (Capa Gratuita GCP) o ~$7.00 USD/mes.
   - **OpenClaw Backend por Agente**: ~$7.00 USD/mes.
   - **Disco Estándar (10 GB)**: ~$0.40 USD/mes.
   - **Costo estimado base total**: **~$7.40 USD - $14.80 USD / mes**.

---

## 🚀 Guía de Despliegue

### 1. Requisitos Previos
- Tener instalado [Terraform](https://www.terraform.io/downloads) (v1.3.0+).
- Tener instalado [Google Cloud CLI (`gcloud`)](https://cloud.google.com/sdk/docs/install).
- Cuenta de GCP con un proyecto activo y facturación habilitada.

### 2. Autenticación en GCP
```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project TU-PROJECT-ID
```

### 3. Configuración de Variables
Copia el archivo de ejemplo y configura tu `project_id`:
```bash
cp terraform.tfvars.example terraform.tfvars
```
Edita `terraform.tfvars`:
```hcl
project_id             = "tu-proyecto-gcp-id"
region                 = "us-central1"
zone                   = "us-central1-a"
backend_instance_count = 1
```

### 4. Inicialización y Despliegue
```bash
# Inicializar los módulos de Terraform
terraform init

# Validar la sintaxis y plan de ejecución
terraform plan

# Aplicar los cambios para crear la infraestructura en GCP
terraform apply
```

---

## 🔒 Aislamiento y Conexión SSH Segura mediante IAP

Para conectarte a la máquina privada de base de datos o backend de OpenClaw sin expone IP pública:

```bash
gcloud compute ssh realstate-db-micro \
    --zone=us-central1-a \
    --tunnel-through-iap
```
