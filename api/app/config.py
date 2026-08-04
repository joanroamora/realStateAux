import os
from pathlib import Path

class Settings:
    API_SECRET_TOKEN: str = os.getenv("API_SECRET_TOKEN", "realstate-secret-token-2026")
    DATA_DIR: Path = Path(os.getenv("DATA_DIR", "/app/data"))
    API_PREFIX: str = os.getenv("API_PREFIX", "/api/v1")
    PROJECT_NAME: str = "RealStateAux Data API"
    VERSION: str = "1.0.0"

settings = Settings()
