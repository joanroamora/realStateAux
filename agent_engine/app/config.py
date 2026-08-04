import os
from pathlib import Path

class Settings:
    PROJECT_NAME: str = "RealStateAux SRE Agent Orchestrator"
    VERSION: str = "1.0.0"
    
    # Clave de cifrado simétrico para credenciales sensibles (WhatsApp, Telegram, LLM Keys)
    ENCRYPTION_MASTER_KEY: str = os.getenv("ENCRYPTION_MASTER_KEY", "uH9sK3l9XQ2zV4wE8rT1yU3iO5pA7sD9fG1hJ3kL5mN=")
    
    # Red privada de Docker para comunicación aislada entre servicios
    DOCKER_NETWORK: str = os.getenv("DOCKER_NETWORK", "realstate-vpc-network")
    
    # Imagen base de OpenClaw
    OPENCLAW_IMAGE: str = os.getenv("OPENCLAW_IMAGE", "realstate-openclaw-agent:latest")
    
    # URL de la Data API interna
    DATA_API_URL: str = os.getenv("DATA_API_URL", "http://host.docker.internal:8000/api/v1")
    DATA_API_TOKEN: str = os.getenv("DATA_API_TOKEN", "realstate-secret-token-2026")
    
    # Límites predeterminados de recursos ajustados para e2-micro
    DEFAULT_MEMORY_LIMIT: str = os.getenv("DEFAULT_MEMORY_LIMIT", "256m")
    DEFAULT_CPU_LIMIT: float = float(os.getenv("DEFAULT_CPU_LIMIT", "0.5"))

settings = Settings()
