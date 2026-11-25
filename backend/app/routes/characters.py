from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from ..db import transaction
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
    melee: int
    armor: int
    current_level_id: int | None
    pos_x: int | None
    pos_y: int | None


@router.get("", response_model=list[Character])
def list_characters(user_id: int = Depends(get_current_user)):
    raise HTTPException(status_code=501, detail="Not implemented")


@router.post("", response_model=Character, status_code=201)
def create_character(body: CharacterCreate, user_id: int = Depends(get_current_user)):
    with transaction() as cur:
        cur.execute(
            "SELECT base_hp, base_melee, base_mana, base_ranged, base_armor, base_speed "
            "FROM character_classes WHERE class_id = %s",
            (body.class_id,),
        )
        cls = cur.fetchone()
        if cls is None:
            raise HTTPException(status_code=400, detail="Unknown class")

        cur.execute(
            "INSERT INTO characters "
            "(user_id, class_id, character_name, hp, max_hp, melee, mana, ranged, armor, speed) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
            (
                user_id,
                body.class_id,
                body.character_name,
                cls["base_hp"],
                cls["base_hp"],
                cls["base_melee"],
                cls["base_mana"],
                cls["base_ranged"],
                cls["base_armor"],
                cls["base_speed"],
            ),
        )
        character_id = cur.lastrowid
        cur.execute(
            "INSERT INTO character_stats (character_id) VALUES (%s)",
            (character_id,),
        )

        cur.execute(
            "SELECT character_id, character_name, class_id, level, xp, hp, max_hp, mana, "
            "melee, armor, current_level_id, pos_x, pos_y "
            "FROM characters WHERE character_id = %s",
            (character_id,),
        )
        character = cur.fetchone()

    return Character(**character)


@router.get("/{character_id}", response_model=Character)
def get_character(character_id: int, user_id: int = Depends(get_current_user)):
    raise HTTPException(status_code=501, detail="Not implemented")


@router.patch("/{character_id}/position", response_model=Character)
def save_position(character_id: int, body: Position, user_id: int = Depends(get_current_user)):
    raise HTTPException(status_code=501, detail="Not implemented")
