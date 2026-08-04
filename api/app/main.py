import json
import logging
from pathlib import Path
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.responses import JSONResponse
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

def get_data_file_path(filename: str) -> Path:
    # 1. Probar ruta configurada en settings
    path = settings.DATA_DIR / filename
    if path.is_file():
        return path
    
    # 2. Probar ruta relativa del proyecto en desarrollo local
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

@app.get("/health", tags=["Salud"])
async def health_check():
    """Endpoint público de monitoreo de salud del servicio."""
    return {"status": "ok", "service": settings.PROJECT_NAME, "version": settings.VERSION}

@app.get(f"{settings.API_PREFIX}/properties", dependencies=[Depends(verify_api_token)], tags=["Inventario"])
async def get_properties():
    """Obtiene el inventario dummy de propiedades inmobiliarias."""
    data = load_json_file("properties_dummy.json")
    return JSONResponse(content={"status": "success", "count": len(data), "data": data})

@app.get(f"{settings.API_PREFIX}/calendar", dependencies=[Depends(verify_api_token)], tags=["Agenda"])
async def get_calendar():
    """Obtiene la disponibilidad de agenda del agente."""
    data = load_json_file("calendar_mock.json")
    return JSONResponse(content={"status": "success", "data": data})

@app.get(f"{settings.API_PREFIX}/faq", dependencies=[Depends(verify_api_token)], tags=["Conocimiento"])
async def get_faq():
    """Obtiene la base de conocimiento y políticas de atención en formato Markdown."""
    content = load_text_file("faq_inmobiliaria.md")
    return JSONResponse(content={"status": "success", "format": "markdown", "content": content})

@app.get(f"{settings.API_PREFIX}/leads", dependencies=[Depends(verify_api_token)], tags=["Leads"])
async def get_leads():
    """Obtiene los perfiles sintéticos de leads de prueba."""
    data = load_json_file("leads_synthetic.json")
    return JSONResponse(content={"status": "success", "count": len(data), "data": data})
