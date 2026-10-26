from contextlib import contextmanager

from mysql.connector import pooling

from .config import DB_CONFIG, POOL_SIZE

_pool = pooling.MySQLConnectionPool(
    pool_name="ashen_pool",
    pool_size=POOL_SIZE,
    **DB_CONFIG,
)


@contextmanager
def transaction():
    conn = _pool.get_connection()
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


def fetch_one(sql: str, params: tuple = ()):
    with transaction() as cur:
        cur.execute(sql, params)
        return cur.fetchone()


def fetch_all(sql: str, params: tuple = ()):
    with transaction() as cur:
        cur.execute(sql, params)
        return cur.fetchall()
