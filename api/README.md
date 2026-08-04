# API REST de Datos Inmobiliarios (FastAPI Ultra-Ligera)

Servicio Backend en **Python (FastAPI)** diseñado para ser desplegado en máquinas de recursos reducidos (**GCP `e2-micro`**). Consume menos de **40 MB de memoria RAM** y procesa respuestas en milisegundos utilizando caché en memoria.

---

## 🔒 Seguridad y Autenticación

Todos los endpoints `/api/v1/*` requieren el encabezado HTTP de autenticación `X-API-Token` (o `Authorization: Bearer <TOKEN>`). 

- **Token Por Defecto**: `realstate-secret-token-2026`
- **Configuración por Variable de Entorno**: `API_SECRET_TOKEN`

---

## 📡 Endpoints REST

| Método | Endpoint | Descripción | Requiere Token |
| :--- | :--- | :--- | :--- |
| `GET` | `/health` | Chequeo de estado de salud del servicio | No |
| `GET` | `/api/v1/properties` | Inventario de propiedades inmobiliarias | **Sí** |
| `GET` | `/api/v1/calendar` | Disponibilidad de agenda del agente | **Sí** |
| `GET` | `/api/v1/faq` | Base de conocimiento y políticas (Markdown) | **Sí** |
| `GET` | `/api/v1/leads` | Perfiles sintéticos de leads de prueba | **Sí** |

---

## 💻 Ejecución Local (Python)

### 1. Crear Entorno Virtual e Instalar Dependencias
```bash
cd api
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 2. Ejecutar la Aplicación
```bash
export API_SECRET_TOKEN="mi-token-super-seguro"
export DATA_DIR="../data"
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

---

## 🐳 Ejecución con Docker

### 1. Construir la Imagen Docker Optimizada
```bash
cd api
docker build -t realstate-api:latest .
```

### 2. Ejecutar el Contenedor
Montando la carpeta de datos `/data`:
```bash
docker run -d \
  --name realstate-data-api \
  -p 8000:8000 \
  -e API_SECRET_TOKEN="realstate-secret-token-2026" \
  -v $(pwd)/../data:/app/data \
  realstate-api:latest
```

---

## 🧪 Pruebas con `curl`

### 1. Healthcheck (Público)
```bash
curl -X GET http://localhost:8000/health
```

### 2. Obtener Propiedades (Con Token)
```bash
curl -X GET http://localhost:8000/api/v1/properties \
  -H "X-API-Token: realstate-secret-token-2026"
```

### 3. Obtener Agenda (Con Token)
```bash
curl -X GET http://localhost:8000/api/v1/calendar \
  -H "X-API-Token: realstate-secret-token-2026"
```

### 4. Obtener FAQ / Políticas (Con Token)
```bash
curl -X GET http://localhost:8000/api/v1/faq \
  -H "X-API-Token: realstate-secret-token-2026"
```

### 5. Prueba de Acceso Denegado (Sin Token)
```bash
curl -i -X GET http://localhost:8000/api/v1/properties
# Retorna: HTTP/1.1 401 Unauthorized
```
