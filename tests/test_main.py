from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_healthz():
    r = client.get("/healthz")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}


def test_create_and_get_item():
    r = client.post("/api/items", json={"name": "router", "quantity": 3})
    assert r.status_code == 201
    item = r.json()
    assert client.get(f"/api/items/{item['id']}").json()["name"] == "router"


def test_validation_rejects_negative_quantity():
    r = client.post("/api/items", json={"name": "switch", "quantity": -1})
    assert r.status_code == 422


def test_unknown_item_returns_404():
    assert client.get("/api/items/9999").status_code == 404
