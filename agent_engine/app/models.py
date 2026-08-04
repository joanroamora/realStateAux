from typing import Optional
from pydantic import BaseModel, EmailStr, Field

class ProvisionRequest(BaseModel):
    user_email: str = Field(..., description="Correo del nuevo usuario/agente inmobiliario")
    agent_id: str = Field(..., description="ID único asignado al agente inmobiliario")
    whatsapp_number: Optional[str] = Field(None, description="Número asignado en WhatsApp Business API")
    telegram_bot_token: Optional[str] = Field(None, description="Token del Bot de Telegram")
    llm_api_key: Optional[str] = Field(None, description="Clave de API de LLM (Claude/GPT)")
    memory_limit: Optional[str] = Field("256m", description="Límite máximo de memoria RAM (ej. 256m)")
    cpu_limit: Optional[float] = Field(0.5, description="Límite máximo de CPUs (ej. 0.5)")

class ProvisionResponse(BaseModel):
    status: str
    message: str
    user_email: str
    agent_id: str
    container_id: str
    container_name: str

class InstanceInfo(BaseModel):
    user_email: str
    agent_id: str
    container_id: str
    container_name: str
    status: str
    image: str
    memory_limit: str
    cpu_limit: float
    created_at: str
