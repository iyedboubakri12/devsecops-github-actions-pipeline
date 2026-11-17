"""Small inventory API used as the workload for the DevSecOps pipeline."""
import os

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(title="inventory-api", version=os.getenv("APP_VERSION", "dev"))

_items: dict[int, "Item"] = {}


class ItemIn(BaseModel):
    name: str = Field(min_length=1, max_length=80)
    quantity: int = Field(ge=0, le=100_000)


class Item(ItemIn):
    id: int


@app.get("/healthz")
def healthz() -> dict:
    return {"status": "ok"}


@app.get("/version")
def version() -> dict:
    return {"version": app.version}


@app.get("/api/items")
def list_items() -> list[Item]:
    return list(_items.values())


@app.post("/api/items", status_code=201)
def create_item(item: ItemIn) -> Item:
    new = Item(id=len(_items) + 1, **item.model_dump())
    _items[new.id] = new
    return new


@app.get("/api/items/{item_id}")
def get_item(item_id: int) -> Item:
    if item_id not in _items:
        raise HTTPException(status_code=404, detail="item not found")
    return _items[item_id]
