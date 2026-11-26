from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from mysql.connector import Error as MySQLError

from .config import CORS_ORIGINS
from .routes import auth, characters, combat, demo, inventory, levels

app = FastAPI(title="Java Knight API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


for router in (auth.router, characters.router, levels.chapters, levels.router, combat.router, inventory.router, demo.router):
    app.include_router(router)


@app.exception_handler(MySQLError)
def database_error_handler(request: Request, _exc: MySQLError) -> JSONResponse:
    return JSONResponse(status_code=503, content={"detail": "Database unavailable"})


@app.get("/health")
def health():
    return {"status": "ok"}
