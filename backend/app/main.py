from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import CORS_ORIGINS
from .routes import auth, characters, combat, demo, inventory, levels

app = FastAPI(title="Ashen Realms API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


for router in (auth.router, characters.router, levels.router, combat.router, inventory.router, demo.router):
    app.include_router(router)


@app.get("/health")
def health():
    return {"status": "ok"}
