from contextlib import contextmanager
from threading import Lock
from typing import Any

from mysql.connector import pooling

from .config import DB_CONFIG, POOL_SIZE

_pool: pooling.MySQLConnectionPool | None = None
_pool_lock = Lock()


def _get_pool() -> pooling.MySQLConnectionPool:
    global _pool
    if _pool is None:
        with _pool_lock:
            if _pool is None:
                _pool = pooling.MySQLConnectionPool(
                    pool_name="java_knight_pool",
                    pool_size=POOL_SIZE,
                    **DB_CONFIG,
                )
    return _pool


@contextmanager
def transaction():
    conn = _get_pool().get_connection()
    cur = conn.cursor(dictionary=True, prepared=True)
    try:
        yield cur
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()


def is_duplicate_key(e) -> bool:
    return e.errno == 1062 or "Duplicate entry" in str(e)


def fetch_one(sql: str, params: tuple[Any, ...] = ()):
    with transaction() as cur:
        cur.execute(sql, params)
        return cur.fetchone()


def fetch_all(sql: str, params: tuple[Any, ...] = ()):
    with transaction() as cur:
        cur.execute(sql, params)
        return cur.fetchall()
