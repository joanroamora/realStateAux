FROM python:3.11-alpine

WORKDIR /app

COPY app.py .

# Usuario no-root para seguridad
RUN adduser -D -u 10001 agentuser && chown -R agentuser:agentuser /app

USER agentuser

CMD ["python", "-u", "app.py"]
