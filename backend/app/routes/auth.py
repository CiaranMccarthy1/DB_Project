import bcrypt
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, EmailStr

from ..db import transaction
from ..security import create_token, get_current_user

router = APIRouter(prefix="/auth", tags=["auth"])


class Register(BaseModel):
    username: str
    email: EmailStr
    password: str


class Login(BaseModel):
    username: str
    password: str


class Token(BaseModel):
    token: str


class User(BaseModel):
    user_id: int
    username: str
    email: str


@router.post("/register", response_model=Token, status_code=201)
def register(body: Register):
    password_hash = bcrypt.hashpw(body.password.encode(), bcrypt.gensalt()).decode()

    with transaction() as cur:
        cur.execute(
            "SELECT user_id FROM users WHERE username = %s OR email = %s",
            (body.username, body.email),
        )
        if cur.fetchone():
            raise HTTPException(status_code=409, detail="Username or email already in use")

        cur.execute(
            "INSERT INTO users (username, email, password_hash) VALUES (%s, %s, %s)",
            (body.username, body.email, password_hash),
        )
        user_id = cur.lastrowid

    if user_id is None:
        raise HTTPException(status_code=500, detail="Could not create user")

    return Token(token=create_token(user_id))


@router.post("/login", response_model=Token)
def login(body: Login):
    with transaction() as cur:
        cur.execute(
            "SELECT user_id, password_hash FROM users WHERE username = %s",
            (body.username,),
        )
        user = cur.fetchone()

    if not user:
        raise HTTPException(status_code=401, detail="Invalid username or password")

    try:
        valid = bcrypt.checkpw(body.password.encode(), user["password_hash"].encode())
    except ValueError:
        valid = False

    if not valid:
        raise HTTPException(status_code=401, detail="Invalid username or password")

    return Token(token=create_token(int(user["user_id"])))


@router.get("/me", response_model=User)
def me(user_id: int = Depends(get_current_user)):
    with transaction() as cur:
        cur.execute(
            "SELECT user_id, username, email FROM users WHERE user_id = %s",
            (user_id,),
        )
        user = cur.fetchone()

    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    return User(**user)
