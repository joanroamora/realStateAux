import sys
from fastapi.testclient import TestClient
from app.main import app
from app.config import settings

client = TestClient(app)

def test_health():
    res = client.get("/health")
    assert res.status_code == 200
    assert res.json()["status"] == "ok"
    print("✅ Healthcheck test passed")

def test_unauthorized():
    res = client.get(f"{settings.API_PREFIX}/properties")
    assert res.status_code == 401
    print("✅ Unauthorized test passed")

def test_get_properties():
    res = client.get(
        f"{settings.API_PREFIX}/properties",
        headers={"X-API-Token": settings.API_SECRET_TOKEN}
    )
    assert res.status_code == 200
    json_data = res.json()
    assert json_data["status"] == "success"
    assert len(json_data["data"]) == 3
    print("✅ Properties test passed:", json_data["count"], "properties loaded")

def test_get_calendar():
    res = client.get(
        f"{settings.API_PREFIX}/calendar",
        headers={"Authorization": f"Bearer {settings.API_SECRET_TOKEN}"}
    )
    assert res.status_code == 200
    json_data = res.json()
    assert json_data["status"] == "success"
    print("✅ Calendar test passed for agent:", json_data["data"]["agente_id"])

def test_get_faq():
    res = client.get(
        f"{settings.API_PREFIX}/faq",
        headers={"X-API-Token": settings.API_SECRET_TOKEN}
    )
    assert res.status_code == 200
    json_data = res.json()
    assert "Proceso de Compra" in json_data["content"]
    print("✅ FAQ test passed")

if __name__ == "__main__":
    try:
        test_health()
        test_unauthorized()
        test_get_properties()
        test_get_calendar()
        test_get_faq()
        print("🎉 ALL API TESTS PASSED SUCCESSFULLY!")
    except Exception as e:
        print("❌ Test failed:", e)
        sys.exit(1)
