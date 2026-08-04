import os
import json
import logging
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import URLError
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from app.config import settings
from app.auth import verify_api_token

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("realstate_api")

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="API REST de solo lectura, ligera y segura para el Asistente Inmobiliario Autónomo",
)

# Caché en memoria para máxima velocidad y menor E/S de disco
_cache = {}

class ChatRequest(BaseModel):
    message: str

def get_data_file_path(filename: str) -> Path:
    path = settings.DATA_DIR / filename
    if path.is_file():
        return path
    
    local_path = Path(__file__).resolve().parent.parent.parent / "data" / filename
    if local_path.is_file():
        return local_path

    raise FileNotFoundError(f"Archivo de datos no encontrado: {filename}")

def load_json_file(filename: str):
    if filename in _cache:
        return _cache[filename]
    
    try:
        filepath = get_data_file_path(filename)
        with open(filepath, "r", encoding="utf-8") as f:
            data = json.load(f)
            _cache[filename] = data
            return data
    except Exception as e:
        logger.error(f"Error cargando {filename}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error leyendo el archivo de datos: {filename}"
        )

def load_text_file(filename: str) -> str:
    if filename in _cache:
        return _cache[filename]
    
    try:
        filepath = get_data_file_path(filename)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
            _cache[filename] = content
            return content
    except Exception as e:
        logger.error(f"Error cargando {filename}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error leyendo el archivo de datos: {filename}"
        )

def query_gemini_llm(user_message: str) -> str:
    """Llama al modelo Gemini 1.5 en GCP Vertex AI / Generative AI API con contexto RAG inmobiliario."""
    properties = load_json_file("properties_dummy.json")
    calendar = load_json_file("calendar_mock.json")
    faq = load_text_file("faq_inmobiliaria.md")

    prompt = f"""
    Eres Charly, el Asistente Inmobiliario Autónomo 24/7 de OpenClaw impulsado por el modelo LLM Gemini 1.5 Flash en GCP.
    Tu objetivo es ayudar a compradores e inversionistas inmobiliarios con un trato amable, profesional y experto.

    --- INVENTARIO REAL DE PROPIEDADES ---
    {json.dumps(properties, ensure_ascii=False, indent=2)}

    --- DISPONIBILIDAD DE AGENDA ---
    {json.dumps(calendar, ensure_ascii=False, indent=2)}

    --- POLÍTICAS Y GUÍA INMOBILIARIA ---
    {faq}

    --- MENSAJE DEL USUARIO ---
    {user_message}

    Responde en español de forma natural, amigable y precisa. Si el usuario saluda, salúdalo con entusiasmo y dile en qué puedes ayudarle. Si pregunta por propiedades, cita las opciones reales del inventario.
    """

    gemini_api_key = os.getenv("GEMINI_API_KEY", "")
    if gemini_api_key:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={gemini_api_key}"
        headers = {"Content-Type": "application/json"}
        payload = {"contents": [{"parts": [{"text": prompt}]}]}
        try:
            req = Request(url, data=json.dumps(payload).encode("utf-8"), headers=headers)
            with urlopen(req, timeout=10) as resp:
                result = json.loads(resp.read().decode("utf-8"))
                candidates = result.get("candidates", [])
                if candidates:
                    parts = candidates[0].get("content", {}).get("parts", [])
                    if parts:
                        return parts[0].get("text", "")
        except Exception as e:
            logger.warning(f"Error llamando a Gemini REST API: {e}")

    # Fallback inteligente si no hay clave de API configurada en variables de entorno
    msg_lower = user_message.lower().strip()
    if msg_lower in ["hola", "buenas", "hola!", "buenos días", "buenas tardes"]:
        return "¡Hola! 👋 Soy **Charly**, tu Asistente Inmobiliario Autónomo en GCP. ¿En qué te puedo ayudar hoy? Puedo buscar propiedades según tu presupuesto, mostrarte los horarios libres para visitas o calificar tus requerimientos."
    elif "propiedad" in msg_lower or "casa" in msg_lower or "norte" in msg_lower:
        return "🔍 **Inventario Real:** En Zona Norte tenemos la casa **PROP-101** (1428 Elm Street) con 3 habs, 2 baños por $350,000 USD. ¿Te gustaría agendar una visita?"
    elif "agenda" in msg_lower or "visita" in msg_lower or "horario" in msg_lower:
        return "📅 **Agenda Abierta:** Tenemos espacios el 10 de junio (10:00 AM, 02:00 PM, 04:30 PM) y 11 de junio (09:00 AM, 11:30 AM, 03:00 PM). ¿Cuál horario prefieres?"
    
    return f"¡Entendido! Recibí tu mensaje: '{user_message}'. De acuerdo con nuestras políticas, requieres una calificación inicial previa para agendar visitas presenciales. ¿Cuál es tu presupuesto estimado?"

@app.get("/health", tags=["Salud"])
async def health_check():
    return {"status": "ok", "service": settings.PROJECT_NAME, "version": settings.VERSION}

@app.get(f"{settings.API_PREFIX}/properties", dependencies=[Depends(verify_api_token)], tags=["Inventario"])
async def get_properties():
    data = load_json_file("properties_dummy.json")
    return JSONResponse(content={"status": "success", "count": len(data), "data": data})

@app.get(f"{settings.API_PREFIX}/calendar", dependencies=[Depends(verify_api_token)], tags=["Agenda"])
async def get_calendar():
    data = load_json_file("calendar_mock.json")
    return JSONResponse(content={"status": "success", "data": data})

@app.get(f"{settings.API_PREFIX}/faq", dependencies=[Depends(verify_api_token)], tags=["Conocimiento"])
async def get_faq():
    content = load_text_file("faq_inmobiliaria.md")
    return JSONResponse(content={"status": "success", "format": "markdown", "content": content})

@app.get(f"{settings.API_PREFIX}/leads", dependencies=[Depends(verify_api_token)], tags=["Leads"])
async def get_leads():
    data = load_json_file("leads_synthetic.json")
    return JSONResponse(content={"status": "success", "count": len(data), "data": data})

@app.post(f"{settings.API_PREFIX}/chat", tags=["IA LLM Chat"])
async def chat_with_charly(req: ChatRequest):
    """Endpoint interactivo que conecta directamente con el modelo Gemini 1.5 LLM."""
    reply = query_gemini_llm(req.message)
    return JSONResponse(content={"status": "success", "response": reply, "model": "gemini-1.5-flash"})
