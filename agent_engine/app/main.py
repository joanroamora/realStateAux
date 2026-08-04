import logging
from typing import List
from fastapi import FastAPI, HTTPException, status, Depends
from app.config import settings
from app.models import ProvisionRequest, ProvisionResponse, InstanceInfo
from app.provisioner import orchestrator

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("admin_api")

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="API Backend del Panel de Administración Central para Aprovisionamiento Dinámico SRE de OpenClaw",
)

@app.on_event("startup")
async def startup_event():
    """Intenta construir la imagen base de OpenClaw al iniciar el orquestador."""
    orchestrator.build_mock_image_if_needed()

@app.get("/health", tags=["Salud Orquestador"])
async def health_check():
    return {
        "status": "ok",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "mode": "SRE Container Orchestration"
    }

@app.post(
    "/admin/provision",
    response_model=ProvisionResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Aprovisionamiento"]
)
async def provision_user_agent(request: ProvisionRequest):
    """
    Registra un nuevo usuario/agente inmobiliario y despliega automáticamente su instancia
    aislada de OpenClaw configurando sus credenciales cifradas y límites de memoria/CPU.
    """
    logger.info(f"Recibida solicitud de alta para usuario: {request.user_email} (Agent ID: {request.agent_id})")
    
    if not request.user_email or "@" not in request.user_email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Correo de usuario inválido"
        )
    
    try:
        response = orchestrator.provision_instance(request)
        return response
    except Exception as e:
        logger.error(f"Error procesando aprovisionamiento: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Fallo en el aprovisionamiento de la instancia: {str(e)}"
        )

@app.get(
    "/admin/instances",
    response_model=List[InstanceInfo],
    tags=["Monitoreo e Instancias"]
)
async def list_agent_instances():
    """Lista las instancias aisladas de OpenClaw activas y monitoreadas."""
    return orchestrator.list_instances()

@app.delete(
    "/admin/deprovision/{user_email:path}",
    tags=["Aprovisionamiento"]
)
async def deprovision_user_agent(user_email: str):
    """Baja y elimina la instancia aislada de OpenClaw para el usuario especificado."""
    success = orchestrator.deprovision_instance(user_email)
    if success:
        return {"status": "success", "message": f"Instancia de {user_email} desaprovisionada correctamente"}
    else:
        return {"status": "info", "message": f"No se encontró instancia activa para {user_email}"}
