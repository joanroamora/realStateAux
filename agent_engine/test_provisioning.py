import sys
from fastapi.testclient import TestClient
from app.main import app
from app.crypto import crypto

client = TestClient(app)

def test_crypto_credentials():
    print("\n--- 1. Probando Cifrado de Credenciales (Fernet/AES-256) ---")
    secret = "sk-proj-llm-key-secret-9999"
    encrypted = crypto.encrypt(secret)
    decrypted = crypto.decrypt(encrypted)
    assert secret == decrypted
    print("✅ Cifrado y descifrado de credenciales verificado:", encrypted[:25] + "...")

def test_admin_provision():
    print("\n--- 2. Probando Endpoint de Alta / Aprovisionamiento (/admin/provision) ---")
    payload = {
        "user_email": "carlos.martinez@inmobiliaria.com",
        "agent_id": "agent_carlos_01",
        "whatsapp_number": "+15550192837",
        "telegram_bot_token": "718293849:AAFx910283719283",
        "llm_api_key": "sk-proj-test123456789",
        "memory_limit": "256m",
        "cpu_limit": 0.5
    }
    res = client.post("/admin/provision", json=payload)
    assert res.status_code == 201
    data = res.json()
    assert data["status"] in ["success", "simulated"]
    assert "openclaw-agent-carlos-martinez-inmobiliaria-com" in data["container_name"]
    print("✅ Aprovisionamiento exitoso:", data["container_name"], "| ID:", data["container_id"])

def test_list_instances():
    print("\n--- 3. Probando Monitoreo de Instancias (/admin/instances) ---")
    res = client.get("/admin/instances")
    assert res.status_code == 200
    instances = res.json()
    print("✅ Instancias monitoreadas en ejecución:", len(instances))

def test_deprovision():
    print("\n--- 4. Probando Baja de Instancia (/admin/deprovision) ---")
    email = "carlos.martinez@inmobiliaria.com"
    res = client.delete(f"/admin/deprovision/{email}")
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "success" or data["status"] == "info"
    print("✅ Desaprovisionamiento exitoso para:", email)

if __name__ == "__main__":
    try:
        test_crypto_credentials()
        test_admin_provision()
        test_list_instances()
        test_deprovision()
        print("\n🎉 ¡TODAS LAS PRUEBAS SRE DE APROVISIONAMIENTO PASARON CON ÉXITO!")
    except Exception as e:
        print("\n❌ Error en prueba SRE:", e)
        sys.exit(1)
