from fastapi import Header, HTTPException, status
from app.config import settings

async def verify_api_token(
    x_api_token: str = Header(None, alias="X-API-Token"),
    authorization: str = Header(None, alias="Authorization")
):
    """
    Verifica el token de seguridad interno en la cabecera X-API-Token o Authorization.
    Restringe el acceso exclusivamente a servicios autorizados (Frontend / OpenClaw Backend).
    """
    token = x_api_token

    if not token and authorization:
        if authorization.startswith("Bearer "):
            token = authorization.split("Bearer ")[1].strip()
        else:
            token = authorization

    if not token or token != settings.API_SECRET_TOKEN:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Acceso no autorizado: Token de API inválido o ausente",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return token
