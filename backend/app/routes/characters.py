from fastapi import APIRouter, Depends, HTTPException
from mysql.connector import Error as MySQLError
from pydantic import BaseModel

from ..db import is_duplicate_key, transaction
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
    with transaction() as cur:
        cur.execute(
            "SELECT character_id, character_name, class_id, level, xp, hp, max_hp, mana, "
            "melee, armor, current_level_id, pos_x, pos_y "
            "FROM characters WHERE user_id = %s ORDER BY character_id",
            (user_id,),
        )
        return [Character(**row) for row in cur.fetchall()]


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

        try:
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
        except MySQLError as e:
            # no pre-check here: the unique key (user_id, character_name) is the guarantee
            if is_duplicate_key(e):
                raise HTTPException(status_code=409, detail="Character name already in use")
            raise
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
    with transaction() as cur:
        cur.execute(
            "SELECT character_id, character_name, class_id, level, xp, hp, max_hp, mana, "
            "melee, armor, current_level_id, pos_x, pos_y "
            "FROM characters WHERE character_id = %s AND user_id = %s",
            (character_id, user_id),
        )
        row = cur.fetchone()
    if row is None:
        raise HTTPException(status_code=404, detail="Character not found")
    return Character(**row)


@router.patch("/{character_id}/position", response_model=Character)
def save_position(character_id: int, body: Position, user_id: int = Depends(get_current_user)):
    with transaction() as cur:
        cur.execute(
            "SELECT character_id FROM characters WHERE character_id = %s AND user_id = %s",
            (character_id, user_id),
        )
        if cur.fetchone() is None:
            raise HTTPException(status_code=404, detail="Character not found")

        # trust boundary: only floor/spawn/door tiles are legal standing spots
        cur.execute(
            "SELECT tile_kind FROM level_tiles "
            "WHERE level_id = %s AND pos_x = %s AND pos_y = %s",
            (body.level_id, body.x, body.y),
        )
        tile = cur.fetchone()
        if tile is None or tile["tile_kind"] not in ("floor", "spawn", "door"):
            raise HTTPException(status_code=400, detail="Position is not a walkable tile")

        cur.execute(
            "UPDATE characters SET current_level_id = %s, pos_x = %s, pos_y = %s "
            "WHERE character_id = %s",
            (body.level_id, body.x, body.y, character_id),
        )
        cur.execute(
            "SELECT character_id, character_name, class_id, level, xp, hp, max_hp, mana, "
            "melee, armor, current_level_id, pos_x, pos_y "
            "FROM characters WHERE character_id = %s",
            (character_id,),
        )
        return Character(**cur.fetchone())
