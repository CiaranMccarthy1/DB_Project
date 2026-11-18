from ..config import JWT_ALGORITHM, JWT_SECRET, JWT_TTL_HOURS


def hash_password(password: str) -> str:
    raise NotImplementedError


def verify_password(password: str, password_hash: str) -> bool:
    raise NotImplementedError


def create_token(user_id: int) -> str:
    raise NotImplementedError


def decode_token(token: str) -> int:
    raise NotImplementedError
