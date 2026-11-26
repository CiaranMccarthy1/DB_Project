from fastapi import APIRouter

from ..db import transaction

router = APIRouter(prefix="/demo", tags=["demo"])

TABLES = (
    "users",
    "characters",
    "character_stats",
    "battles",
    "character_inventory",
    "levels",
    "level_tiles",
)


@router.get("")
def demo_summary():
    with transaction() as cur:
        counts = {}
        for table in TABLES:
            cur.execute(f"SELECT COUNT(*) AS n FROM {table}")
            counts[table] = cur.fetchone()["n"]
        cur.execute("SELECT username FROM users ORDER BY user_id")
        accounts = [row["username"] for row in cur.fetchall()]
    return {"tables": counts, "accounts": accounts}
