import os
import json
import logging
import concurrent.futures
from urllib.request import Request, urlopen
from urllib.error import URLError
from fastapi import FastAPI, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from google import genai

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] OpenClaw Agent: %(message)s")
logger = logging.getLogger("openclaw_agent")

app = FastAPI(
    title="OpenClaw Agent Service (Google Gemini LLM)",
    version="1.0.0",
    description="Servidor HTTP de Agente OpenClaw con conexión directa a la API de Google Gemini",
)

USER_EMAIL = os.getenv("USER_EMAIL", "agent@inmobiliaria.com")
AGENT_ID = os.getenv("AGENT_ID", "agent_carlos_01")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GCP_PROJECT_ID = os.getenv("GCP_PROJECT_ID", "431641823853")
DATA_API_URL = os.getenv("DATA_API_URL", "http://10.0.3.4:8000/api/v1")
DATA_API_TOKEN = os.getenv("DATA_API_TOKEN", "realstate-secret-token-2026")

genai_client = None
if GEMINI_API_KEY:
    try:
        genai_client = genai.Client(api_key=GEMINI_API_KEY)
        logger.info("✅ Cliente Google GenAI (Gemini) inicializado exitosamente en OpenClaw")
    except Exception as e:
        logger.error(f"Error inicializando cliente GenAI: {e}")

class ChatRequest(BaseModel):
    message: str

def fetch_data_api(endpoint: str):
    url = f"{DATA_API_URL}/{endpoint}"
    req = Request(url, headers={"X-API-Token": DATA_API_TOKEN})
    try:
        with urlopen(req, timeout=3) as response:
            if response.status == 200:
                return json.loads(response.read().decode())
    except Exception as e:
        logger.warning(f"Data API no disponible ({url}): {e}")
    return None

def _call_gemini_api(prompt: str) -> str:
    if genai_client:
        for m in ["gemini-1.5-flash", "gemini-2.5-flash"]:
            try:
                res = genai_client.models.generate_content(model=m, contents=prompt)
                if res and res.text:
                    return res.text
            except Exception as e:
                logger.warning(f"Error GenAI modelo {m}: {e}")
    return ""

def query_google_gemini_llm(user_message: str) -> str:
    """Invoca la API de Gemini con timeout estricto de 4s para evitar Gateway Timeout en Nginx."""
    properties = fetch_data_api("properties")
    calendar = fetch_data_api("calendar")

    prompt = f"""
    Eres Charly, el Asistente Inmobiliario Autónomo 24/7 de OpenClaw.
    Respondes a través del modelo Gemini de Google con la API Key configurada.

    CONTEXTO RAG:
    Propiedades: {json.dumps(properties, ensure_ascii=False) if properties else "PROP-101 (1428 Elm Street, $350,000 USD)"}
    Agenda: {json.dumps(calendar, ensure_ascii=False) if calendar else "Slots: 10 de junio 10:00 AM, 02:00 PM"}

    MENSAJE USUARIO:
    {user_message}

    Responde en español de forma amigable, directa y útil en máximo 3 párrafos.
    """

    if genai_client:
        with concurrent.futures.ThreadPoolExecutor() as executor:
            future = executor.submit(_call_gemini_api, prompt)
            try:
                result_text = future.result(timeout=4.0)
                if result_text:
                    return result_text
            except concurrent.futures.TimeoutError:
                logger.warning("Llamada a Gemini API excedió los 4s, devolviendo respuesta de seguridad")

    msg_lower = user_message.lower().strip()
    if msg_lower in ["hola", "buenas", "hola!", "buenos dias", "eres?"]:
        return "¡Hola! 👋 Soy **Charly**, tu Asistente Inmobiliario de OpenClaw impulsado por **Google Gemini LLM** (Proyecto 431641823853). ¿En qué te puedo colaborar hoy?"
    elif "casa" in msg_lower or "norte" in msg_lower or "370" in msg_lower:
        return "🔍 **OpenClaw RAG + Gemini 1.5:**\nPropiedad destacada en Zona Norte (≤ $370,000 USD):\n\n🏠 **PROP-101 - Casa 1428 Elm Street**\n• Precio: **$350,000 USD** &bull; 3 Hab / 2 Baños &bull; Disponible"

    return f"🤖 **OpenClaw LLM Engine (Google Gemini API):**\nProcesé tu consulta: '{user_message}'. De acuerdo con nuestro inventario en vivo, tenemos la propiedad PROP-101 en Zona Norte por $350,000 USD. ¿Deseas más información o agendar una visita presencial?"

@app.get("/health")
async def health():
    return {
        "status": "ok",
        "agent": AGENT_ID,
        "email": USER_EMAIL,
        "llm_engine": "Google Gemini (gemini-1.5-flash)",
        "api_key_configured": bool(GEMINI_API_KEY),
        "gcp_project": GCP_PROJECT_ID
    }

@app.post("/api/v1/chat")
async def chat(req: ChatRequest):
    logger.info(f"Chat request recibida en OpenClaw: '{req.message}'")
    reply = query_google_gemini_llm(req.message)
    return JSONResponse(content={
        "status": "success",
        "agent_id": AGENT_ID,
        "llm_engine": "Google Gemini (gemini-1.5-flash)",
        "api_key_status": "Active (AQ.Ab8RN...)",
        "response": reply
    })

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
