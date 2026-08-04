# Image base ligera y optimizada
FROM python:3.11-slim as builder

WORKDIR /app

# Instalar dependencias sin cache de pip para reducir tamaño
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Etapa final ultra ligera
FROM python:3.11-slim

WORKDIR /app

# Crear usuario sin privilegios de root para maxima seguridad
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser:appuser /app

# Copiar dependencias instaladas desde la etapa builder
COPY --from=builder /root/.local /home/appuser/.local
COPY app /app/app

# Variables de entorno por defecto
ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    API_SECRET_TOKEN=realstate-secret-token-2026 \
    DATA_DIR=/app/data

# Exponer el puerto 8000
EXPOSE 8000

# Cambiar a usuario no-root
USER appuser

# Comando de ejecucion optimizado para 1 worker (ideal para e2-micro)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
