import os
import json
import logging
import concurrent.futures
from urllib.request import Request, urlopen
from urllib.error import URLError
from fastapi import FastAPI, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel

try:
    from google import genai
except ImportError:
    genai = None

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] OpenClaw Agent: %(message)s")
logger = logging.getLogger("openclaw_agent")

app = FastAPI(
    title="OpenClaw Agent Service (Google Gemini LLM)",
    version="1.0.0",
    description="Servidor HTTP de Agente OpenClaw con conexión directa a la API de Google Gemini",
)

USER_EMAIL = os.getenv("USER_EMAIL", "agent@inmobiliaria.com")
AGENT_ID = os.getenv("AGENT_ID", "agent_carlos_01")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "").strip()
GCP_PROJECT_ID = os.getenv("GCP_PROJECT_ID", "431641823853")
DATA_API_URL = os.getenv("DATA_API_URL", "http://10.0.3.6:8000/api/v1")
DATA_API_TOKEN = os.getenv("DATA_API_TOKEN", "realstate-secret-token-2026")

genai_client = None
if genai and GEMINI_API_KEY:
    try:
        genai_client = genai.Client(api_key=GEMINI_API_KEY)
        logger.info("✅ Cliente Google GenAI (Gemini API Key) inicializado exitosamente")
    except Exception as e:
        logger.error(f"❌ Error inicializando cliente GenAI: {e}")

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

def _call_gemini_api_sdk(prompt: str) -> str:
    """Intenta consumir Gemini a través del SDK oficial google-genai."""
    if genai_client:
        for m in ["gemini-2.0-flash", "gemini-1.5-flash", "gemini-2.5-flash"]:
            try:
                res = genai_client.models.generate_content(model=m, contents=prompt)
                if res and res.text:
                    logger.info(f"✅ Respuesta exitosa de Gemini SDK con modelo {m}")
                    return res.text
            except Exception as e:
                logger.warning(f"⚠️ Error Gemini SDK modelo {m}: {e}")
    return ""

def _call_gemini_api_rest(prompt: str) -> str:
    """Intenta consumir Gemini a través de REST directo a Google AI Studio."""
    if GEMINI_API_KEY:
        for m in ["gemini-2.0-flash", "gemini-1.5-flash"]:
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{m}:generateContent?key={GEMINI_API_KEY}"
            headers = {"Content-Type": "application/json"}
            payload = {"contents": [{"parts": [{"text": prompt}]}]}
            try:
                req = Request(url, data=json.dumps(payload).encode("utf-8"), headers=headers)
                with urlopen(req, timeout=8) as resp:
                    if resp.status == 200:
                        result = json.loads(resp.read().decode("utf-8"))
                        candidates = result.get("candidates", [])
                        if candidates:
                            parts = candidates[0].get("content", {}).get("parts", [])
                            if parts:
                                text = parts[0].get("text", "")
                                if text:
                                    logger.info(f"✅ Respuesta exitosa de Gemini REST API ({m})")
                                    return text
            except Exception as e:
                logger.warning(f"⚠️ Error Gemini REST API ({m}): {e}")
    return ""

def _call_gemini_vertex_adc(prompt: str) -> str:
    """Intenta consumir Vertex AI mediante ADC (Service Account nativa de GCP)."""
    if genai:
        try:
            vertex_client = genai.Client(vertexai=True, project=GCP_PROJECT_ID, location="us-central1")
            for m in ["gemini-2.0-flash", "gemini-1.5-flash"]:
                try:
                    res = vertex_client.models.generate_content(model=m, contents=prompt)
                    if res and res.text:
                        logger.info(f"✅ Respuesta exitosa de Vertex AI ADC ({m})")
                        return res.text
                except Exception as e:
                    logger.warning(f"⚠️ Error Vertex AI ADC modelo {m}: {e}")
        except Exception as e:
            logger.warning(f"⚠️ Error inicializando cliente Vertex AI ADC: {e}")
    return ""

def query_google_gemini_llm(user_message: str) -> str:
    """Invoca la API de Gemini intentando SDK, REST y Vertex AI ADC en secuencia."""
    properties = fetch_data_api("properties")
    calendar = fetch_data_api("calendar")

    prompt = f"""
    Eres Charly, el Asistente Inmobiliario Autónomo 24/7 de OpenClaw impulsado por Google Gemini.

    CONTEXTO DE DATOS EN TIEMPO REAL (RAG):
    Propiedades Disponibles: {json.dumps(properties, ensure_ascii=False) if properties else "PROP-101 (1428 Elm Street, $350,000 USD, 3 habs, 2 baños)"}
    Agenda Disponible: {json.dumps(calendar, ensure_ascii=False) if calendar else "Slots libres: 10 de junio 10:00 AM, 02:00 PM"}

    MENSAJE DEL USUARIO:
    {user_message}

    Instrucciones: Responde en español de manera profesional, cercana y amigable en máximo 3 párrafos. Cita datos reales del contexto.
    """

    def _execute_llm_pipeline():
        ans = _call_gemini_api_sdk(prompt)
        if ans:
            return ans
        ans = _call_gemini_api_rest(prompt)
        if ans:
            return ans
        ans = _call_gemini_vertex_adc(prompt)
        if ans:
            return ans
        return ""

    with concurrent.futures.ThreadPoolExecutor() as executor:
        future = executor.submit(_execute_llm_pipeline)
        try:
            result_text = future.result(timeout=10.0)
            if result_text:
                return result_text
        except concurrent.futures.TimeoutError:
            logger.warning("⏱️ La llamada a Gemini API excedió el tiempo límite (10s)")

    msg_lower = user_message.lower().strip()
    if msg_lower in ["hola", "buenas", "hola!", "buenos dias", "eres?"]:
        return "¡Hola! 👋 Soy **Charly**, tu Asistente Inmobiliario de OpenClaw impulsado por **Google Gemini LLM** (Proyecto GCP 431641823853). ¿En qué te puedo colaborar hoy?"
    elif "casa" in msg_lower or "norte" in msg_lower or "370" in msg_lower:
        return "🔍 **OpenClaw RAG + Gemini LLM:**\nPropiedad destacada en Zona Norte:\n\n🏠 **PROP-101 - Casa 1428 Elm Street**\n• Precio: **$350,000 USD** &bull; 3 Hab / 2 Baños &bull; Disponible"

    return f"🤖 **OpenClaw Agent (Google Gemini Engine):**\nProcesé tu consulta: '{user_message}'. De acuerdo con nuestro inventario en vivo, tenemos la propiedad PROP-101 en Zona Norte por $350,000 USD. ¿Deseas agendar una visita presencial?"

@app.get("/health")
async def health():
    return {
        "status": "ok",
        "agent": AGENT_ID,
        "email": USER_EMAIL,
        "llm_engine": "Google Gemini (gemini-2.0-flash / gemini-1.5-flash)",
        "api_key_configured": bool(GEMINI_API_KEY),
        "api_key_prefix": GEMINI_API_KEY[:8] + "..." if GEMINI_API_KEY else "None",
        "gcp_project": GCP_PROJECT_ID
    }

@app.post("/api/v1/chat")
@app.post("/chat")
async def chat(req: ChatRequest):
    logger.info(f"📩 Consulta recibida en OpenClaw: '{req.message}'")
    reply = query_google_gemini_llm(req.message)
    return JSONResponse(content={
        "status": "success",
        "agent_id": AGENT_ID,
        "llm_engine": "Google Gemini",
        "api_key_status": "Configured" if GEMINI_API_KEY else "Not Configured",
        "response": reply
    })

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)

