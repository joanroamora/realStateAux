# Orquestador SRE y Motor de Agentes OpenClaw (`/agent_engine`)

Módulo del **Ingeniero de Confiabilidad de Sitios (SRE)** y panel de administración backend para el **aprovisionamiento dinámico, cifrado de credenciales y aislamiento de contenedores OpenClaw multi-usuario** en **GCP (`e2-micro`)**.

---

## 🏗️ Arquitectura de Aprovisionamiento SRE

```
                              +------------------------------------+
                              |  Panel de Administración (Backend) |
                              |      POST /admin/provision         |
                              +------------------------------------+
                                                |
                   +----------------------------+----------------------------+
                   | Validar Usuario y Cifrar Credenciales (AES-256)        |
                   +----------------------------+----------------------------+
                                                |
                                                v
                              +------------------------------------+
                              |   Docker Orchestrator Engine       |
                              |  (--memory=256m  --cpus=0.5)       |
                              +------------------------------------+
                                                |
                 +------------------------------+------------------------------+
                 |                                                             |
                 v                                                             v
  +-------------------------------+                             +-------------------------------+
  |  Contenedor Aislado OpenClaw  |                             |  Contenedor Aislado OpenClaw  |
  |  (Usuario 1: carlos@...com)   |                             |  (Usuario 2: sofia@...com)    |
  |  - Credenciales Cifradas      |                             |  - Credenciales Cifradas      |
  |  - Consume Data API           |                             |  - Consume Data API           |
  +-------------------------------+                             +-------------------------------+
```

---

## 🔒 1. Cifrado de Credenciales y Seguridad

Cada nuevo usuario ingresa sus credenciales de integración (WhatsApp Business API, Telegram Bot Token, y LLM API Keys). 

- El módulo [`app/crypto.py`](file:///home/joanr/agentic-platforms/GCP/realStateAux/agent_engine/app/crypto.py) aplica cifrado simétrico **Fernet (AES-256)** utilizando una clave maestra de orquestación (`ENCRYPTION_MASTER_KEY`).
- Las credenciales nunca se almacenan en texto plano en disco ni en logs.

---

## ⚡ 2. Asignación Estricta de Recursos (e2-micro)

Cada contenedor aislado de OpenClaw se provisiona con límites explícitos de la API de Docker para evitar que un usuario sature la CPU o memoria RAM de la instancia VM `e2-micro`:

- **Límite de Memoria RAM**: `--memory 256m` (Máximo 256 MB por agente).
- **Límite de Cómputo CPU**: `--cpus 0.5` (Máximo 50% de un núcleo vCPU).
- **Aislamiento de Red**: Conexión exclusiva dentro de la red interna privada de la VPC.

---

## 📡 3. API Backend de Administración

| Método | Endpoint | Descripción |
| :--- | :--- | :--- |
| `POST` | `/admin/provision` | Recibe datos del usuario, valida alta y despliega contenedor aislado de OpenClaw. |
| `GET` | `/admin/instances` | Lista los contenedores de agentes activos con su estado y límites de recursos. |
| `DELETE` | `/admin/deprovision/{email}` | Desaprovisiona, detiene y elimina el contenedor del usuario de forma limpia. |
| `GET` | `/health` | Chequeo de estado de salud del orquestador SRE. |

### Ejemplo de Payload JSON (`POST /admin/provision`):
```json
{
  "user_email": "carlos.martinez@inmobiliaria.com",
  "agent_id": "agent_carlos_01",
  "whatsapp_number": "+15550192837",
  "telegram_bot_token": "718293849:AAFx910283719283",
  "llm_api_key": "sk-proj-test123456789",
  "memory_limit": "256m",
  "cpu_limit": 0.5
}
```

---

## 🚀 4. Guía de Ejecución y Pruebas

### Ejecutar Pruebas Automatizadas SRE:
```bash
cd agent_engine
python3 test_provisioning.py
```

### Iniciar el Backend del Panel de Administración:
```bash
cd agent_engine
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload
```
