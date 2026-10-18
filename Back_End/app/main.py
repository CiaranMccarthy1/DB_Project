from fastapi import FastAPI

from .config import CORS_ORIGINS
from .routes import auth, characters, inventory, levels

app = FastAPI(title="Ashen Realms API", version="0.1.0")


for router in (auth.router, characters.router, levels.router, inventory.router):
    app.include_router(router)


@app.get("/health")
def health():
    return {"status": "ok"}
