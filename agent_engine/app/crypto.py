import base64
import hashlib
from cryptography.fernet import Fernet
from app.config import settings

def _get_fernet_key(secret: str) -> bytes:
    """Deriva una clave Fernet válida de 32 bytes en base64 desde un secreto."""
    key_hash = hashlib.sha256(secret.encode()).digest()
    return base64.urlsafe_b64encode(key_hash)

class CredentialCrypto:
    def __init__(self):
        fernet_key = _get_fernet_key(settings.ENCRYPTION_MASTER_KEY)
        self.cipher = Fernet(fernet_key)

    def encrypt(self, plain_text: str) -> str:
        """Cifra credenciales sensibles (tokens, API keys) antes de persistirlas/inyectarlas."""
        if not plain_text:
            return ""
        return self.cipher.encrypt(plain_text.encode()).decode()

    def decrypt(self, cipher_text: str) -> str:
        """Descifra credenciales cifradas para inyección en tiempo de ejecución."""
        if not cipher_text:
            return ""
        try:
            return self.cipher.decrypt(cipher_text.encode()).decode()
        except Exception:
            # Retornar texto tal cual si no estaba cifrado (fallback de desarrollo)
            return cipher_text

crypto = CredentialCrypto()
