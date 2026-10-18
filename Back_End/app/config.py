import os

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "host.docker.internal"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "user": os.getenv("DB_USER", "ashen_app"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "ashen_realms"),
    "charset": "utf8mb4",
    "autocommit": False,
}

POOL_SIZE = int(os.getenv("DB_POOL_SIZE", "10"))

JWT_SECRET = os.environ["JWT_SECRET"]
JWT_ALGORITHM = "HS256"
JWT_TTL_HOURS = 24

CORS_ORIGINS = os.getenv("CORS_ORIGINS", "http://localhost:8080").split(",")
