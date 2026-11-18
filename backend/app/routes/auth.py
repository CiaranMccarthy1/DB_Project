from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, EmailStr

from ..security import get_current_user

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


@router.post("/register", response_model=Token)
def register(body: Register):
    raise HTTPException(status_code=501, detail="Not implemented")


@router.post("/login", response_model=Token)
def login(body: Login):
    raise HTTPException(status_code=501, detail="Not implemented")


@router.get("/me", response_model=User)
def me(user_id: int = Depends(get_current_user)):
    raise HTTPException(status_code=501, detail="Not implemented")
