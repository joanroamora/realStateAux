FROM python:3.11-alpine

WORKDIR /app

RUN pip install --no-cache-dir fastapi uvicorn pydantic google-genai

COPY app.py .

# Usuario no-root para seguridad
RUN adduser -D -u 10001 agentuser && chown -R agentuser:agentuser /app

USER agentuser

EXPOSE 8080

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
