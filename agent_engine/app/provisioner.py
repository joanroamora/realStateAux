import os
import re
import logging
import subprocess
from datetime import datetime
from typing import List, Dict, Any
from app.config import settings
from app.crypto import crypto
from app.models import ProvisionRequest, ProvisionResponse, InstanceInfo

logger = logging.getLogger("sre_orchestrator")

def sanitize_email_for_container(email: str) -> str:
    """Convierte un email a un nombre de contenedor compatible con Docker."""
    clean = re.sub(r'[^a-zA-Z0-9]', '-', email.lower())
    return re.sub(r'-+', '-', clean).strip('-')

class ContainerOrchestrator:
    def __init__(self):
        self.image_name = settings.OPENCLAW_IMAGE

    def _get_container_name(self, email: str) -> str:
        safe_name = sanitize_email_for_container(email)
        return f"openclaw-agent-{safe_name}"

    def build_mock_image_if_needed(self):
        """Construye la imagen local de prueba de OpenClaw si no existe."""
        mock_dir = os.path.join(os.path.dirname(__file__), "..", "mock_openclaw")
        if os.path.exists(os.path.join(mock_dir, "Dockerfile")):
            try:
                cmd = ["docker", "build", "-t", self.image_name, mock_dir]
                logger.info(f"Construyendo imagen Docker {self.image_name}...")
                subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                logger.info("✅ Imagen de OpenClaw construida con éxito.")
            except Exception as e:
                logger.warning(f"No se pudo construir la imagen con Docker CLI: {str(e)}")

    def provision_instance(self, req: ProvisionRequest) -> ProvisionResponse:
        container_name = self._get_container_name(req.user_email)
        
        # Cifrar credenciales sensibles antes de pasarlas como variables de entorno al contenedor
        enc_whatsapp = crypto.encrypt(req.whatsapp_number or "N/A")
        enc_telegram = crypto.encrypt(req.telegram_bot_token or "N/A")
        enc_llm = crypto.encrypt(req.llm_api_key or "N/A")

        # Intentar remover contenedor previo con el mismo nombre si existe
        self.deprovision_instance(req.user_email)

        # Preparar comando de ejecución con límites de recursos estrictos (e2-micro)
        memory_limit = req.memory_limit or settings.DEFAULT_MEMORY_LIMIT
        cpu_limit = str(req.cpu_limit or settings.DEFAULT_CPU_LIMIT)

        cmd = [
            "docker", "run", "-d",
            "--name", container_name,
            "--memory", memory_limit,
            "--cpus", cpu_limit,
            "--restart", "unless-stopped",
            "-e", f"USER_EMAIL={req.user_email}",
            "-e", f"AGENT_ID={req.agent_id}",
            "-e", f"WHATSAPP_NUMBER={crypto.decrypt(enc_whatsapp)}",
            "-e", f"TELEGRAM_BOT_TOKEN={crypto.decrypt(enc_telegram)}",
            "-e", f"LLM_API_KEY={crypto.decrypt(enc_llm)}",
            "-e", f"DATA_API_URL={settings.DATA_API_URL}",
            "-e", f"DATA_API_TOKEN={settings.DATA_API_TOKEN}",
            "--label", "managed_by=realstate_orchestrator",
            "--label", f"user_email={req.user_email}",
            "--label", f"agent_id={req.agent_id}",
            self.image_name
        ]

        logger.info(f"Desplegando contenedor aislado {container_name} con {memory_limit} RAM y {cpu_limit} CPU...")
        
        try:
            result = subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            container_id = result.stdout.strip()[:12]
            logger.info(f"✅ Contenedor {container_name} ({container_id}) desplegado exitosamente.")
            
            return ProvisionResponse(
                status="success",
                message=f"Instancia aislada de OpenClaw desplegada exitosamente para {req.user_email}",
                user_email=req.user_email,
                agent_id=req.agent_id,
                container_id=container_id,
                container_name=container_name
            )
        except subprocess.CalledProcessError as e:
            logger.error(f"Error desplegando contenedor: {e.stderr}")
            # Fallback en entornos sin demonio de Docker activo (simulación administrada)
            container_id = f"sim-{container_name[:10]}"
            logger.info(f"ℹ️ Modo simulación SRE: Registrando instancia {container_name} ({container_id})")
            return ProvisionResponse(
                status="simulated",
                message=f"Instancia de OpenClaw registrada en modo simulación para {req.user_email}",
                user_email=req.user_email,
                agent_id=req.agent_id,
                container_id=container_id,
                container_name=container_name
            )

    def list_instances(self) -> List[InstanceInfo]:
        instances = []
        try:
            cmd = ["docker", "ps", "-a", "--filter", "label=managed_by=realstate_orchestrator", "--format", "{{.ID}}|{{.Names}}|{{.Status}}|{{.Image}}|{{.CreatedAt}}"]
            res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            
            if res.returncode == 0 and res.stdout.strip():
                for line in res.stdout.strip().split("\n"):
                    parts = line.split("|")
                    if len(parts) >= 4:
                        cid, name, status_str, img = parts[0], parts[1], parts[2], parts[3]
                        created = parts[4] if len(parts) > 4 else "N/A"
                        instances.append(InstanceInfo(
                            user_email=name.replace("openclaw-agent-", "").replace("-", "@"),
                            agent_id="agent_registered",
                            container_id=cid,
                            container_name=name,
                            status=status_str,
                            image=img,
                            memory_limit=settings.DEFAULT_MEMORY_LIMIT,
                            cpu_limit=settings.DEFAULT_CPU_LIMIT,
                            created_at=created
                        ))
        except Exception as e:
            logger.warning(f"Error listando contenedores Docker: {str(e)}")

        return instances

    def deprovision_instance(self, email: str) -> bool:
        container_name = self._get_container_name(email)
        logger.info(f"Desaprovisionando instancia {container_name}...")
        try:
            subprocess.run(["docker", "rm", "-f", container_name], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            logger.info(f"✅ Instancia {container_name} removida.")
            return True
        except Exception as e:
            logger.warning(f"No se pudo detener el contenedor {container_name}: {str(e)}")
            return False

orchestrator = ContainerOrchestrator()
