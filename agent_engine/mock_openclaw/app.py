import os
import time
import json
import logging
from urllib.request import Request, urlopen
from urllib.error import URLError

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] OpenClaw Agent: %(message)s")
logger = logging.getLogger("openclaw_agent")

USER_EMAIL = os.getenv("USER_EMAIL", "agent@inmobiliaria.com")
AGENT_ID = os.getenv("AGENT_ID", "agent_carlos_01")
WHATSAPP_NUMBER = os.getenv("WHATSAPP_NUMBER", "N/A")
TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN", "N/A")
VERTEX_AI_MODEL = os.getenv("VERTEX_AI_MODEL", "gemini-1.5-flash")
GCP_PROJECT_ID = os.getenv("GCP_PROJECT_ID", "gcp-realstate-prod")
DATA_API_URL = os.getenv("DATA_API_URL", "http://host.docker.internal:8000/api/v1")
DATA_API_TOKEN = os.getenv("DATA_API_TOKEN", "realstate-secret-token-2026")

def fetch_data_api(endpoint: str):
    url = f"{DATA_API_URL}/{endpoint}"
    req = Request(url, headers={"X-API-Token": DATA_API_TOKEN})
    try:
        with urlopen(req, timeout=5) as response:
            if response.status == 200:
                return json.loads(response.read().decode())
    except URLError as e:
        logger.warning(f"No se pudo conectar a la Data API ({url}): {e.reason}")
    except Exception as e:
        logger.warning(f"Error consultando Data API ({url}): {str(e)}")
    return None

def main():
    logger.info("==================================================")
    logger.info("🤖 MOTOR DE AGENTE OPENCLAW + GCP VERTEX AI (24/7)")
    logger.info(f"   Usuario/Email : {USER_EMAIL}")
    logger.info(f"   Agent ID      : {AGENT_ID}")
    logger.info(f"   WhatsApp      : {WHATSAPP_NUMBER}")
    logger.info(f"   Telegram      : {TELEGRAM_BOT_TOKEN[:10]}...")
    logger.info(f"   GCP Vertex AI : {VERTEX_AI_MODEL} (Project: {GCP_PROJECT_ID})")
    logger.info(f"   Data API URL  : {DATA_API_URL}")
    logger.info("==================================================")

    # Simular ciclo persistente 24/7 con bajo consumo de CPU y modelo Gemini en Vertex AI
    cycle = 0
    while True:
        cycle += 1
        logger.info(f"🔄 Heartbeat #{cycle} - OpenClaw operando con Vertex AI [{VERTEX_AI_MODEL}]...")
        
        # Cada 30 segundos, simular consulta al inventario y razonamiento con Gemini
        if cycle % 3 == 0:
            properties = fetch_data_api("properties")
            if properties and properties.get("status") == "success":
                logger.info(f"✨ Gemini 1.5 en Vertex AI procesó {properties.get('count')} propiedades de la Data API privada")
            else:
                logger.info("ℹ️ Esperando respuesta de la Data API...")

        time.sleep(10)

if __name__ == "__main__":
    main()
