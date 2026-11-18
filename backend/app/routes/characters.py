from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from ..security import get_current_user

router = APIRouter(prefix="/characters", tags=["characters"])


class CharacterCreate(BaseModel):
    class_id: int
    character_name: str


class Position(BaseModel):
    level_id: int
    x: int
    y: int


class Character(BaseModel):
    character_id: int
    character_name: str
    class_id: int
    level: int
    xp: int
    hp: int
    max_hp: int
    mana: int
    current_level_id: int | None
    pos_x: int | None
    pos_y: int | None


@router.get("", response_model=list[Character])
def list_characters(user_id: int = Depends(get_current_user)):
    raise HTTPException(status_code=501, detail="Not implemented")


@router.post("", response_model=Character)
def create_character(body: CharacterCreate, user_id: int = Depends(get_current_user)):
    raise HTTPException(status_code=501, detail="Not implemented")


@router.get("/{character_id}", response_model=Character)
def get_character(character_id: int, user_id: int = Depends(get_current_user)):
    raise HTTPException(status_code=501, detail="Not implemented")


@router.patch("/{character_id}/position", response_model=Character)
def save_position(character_id: int, body: Position, user_id: int = Depends(get_current_user)):
    raise HTTPException(status_code=501, detail="Not implemented")
