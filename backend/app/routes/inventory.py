from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from ..db import transaction
from ..security import get_current_user

router = APIRouter(prefix="/inventory", tags=["inventory"])


class InventoryItem(BaseModel):
    item_id: int
    item_name: str
    sprite: str
    quantity: int


class UseItem(BaseModel):
    character_id: int
    item_id: int


class UseResult(BaseModel):
    hp: int
    quantity: int


def consume_item(cur, character_id: int, item_id: int) -> tuple[int, int]:
    """Heal the character with one item and return (new hp, remaining quantity)."""
    cur.execute(
        "SELECT ci.quantity, i.effect_value "
        "FROM character_inventory ci "
        "JOIN items i ON i.item_id = ci.item_id "
        "WHERE ci.character_id = %s AND ci.item_id = %s "
        "FOR UPDATE",
        (character_id, item_id),
    )
    stack = cur.fetchone()
    if stack is None:
        raise HTTPException(status_code=404, detail="Item not in inventory")

    cur.execute(
        "SELECT hp, max_hp FROM characters WHERE character_id = %s FOR UPDATE",
        (character_id,),
    )
    character = cur.fetchone()
    if character["hp"] >= character["max_hp"]:
        raise HTTPException(status_code=400, detail="HP already full")

    hp = min(character["max_hp"], character["hp"] + stack["effect_value"])
    cur.execute(
        "UPDATE characters SET hp = %s WHERE character_id = %s",
        (hp, character_id),
    )
    if stack["quantity"] == 1:
        cur.execute(
            "DELETE FROM character_inventory WHERE character_id = %s AND item_id = %s",
            (character_id, item_id),
        )
    else:
        cur.execute(
            "UPDATE character_inventory SET quantity = quantity - 1 "
            "WHERE character_id = %s AND item_id = %s",
            (character_id, item_id),
        )
    cur.execute(
        "UPDATE character_stats SET items_used = items_used + 1 WHERE character_id = %s",
        (character_id,),
    )
    return hp, stack["quantity"] - 1


@router.get("", response_model=list[InventoryItem])
def list_inventory(character_id: int, user_id: int = Depends(get_current_user)):
    with transaction() as cur:
        cur.execute(
            "SELECT character_id FROM characters WHERE character_id = %s AND user_id = %s",
            (character_id, user_id),
        )
        if cur.fetchone() is None:
            raise HTTPException(status_code=404, detail="Character not found")

        cur.execute(
            "SELECT i.item_id, i.item_name, i.sprite, ci.quantity "
            "FROM character_inventory ci "
            "JOIN items i ON i.item_id = ci.item_id "
            "WHERE ci.character_id = %s "
            "ORDER BY i.item_id",
            (character_id,),
        )
        return [InventoryItem(**row) for row in cur.fetchall()]


@router.post("/use", response_model=UseResult)
def use_item(body: UseItem, user_id: int = Depends(get_current_user)):
    with transaction() as cur:
        cur.execute(
            "SELECT character_id FROM characters WHERE character_id = %s AND user_id = %s",
            (body.character_id, user_id),
        )
        if cur.fetchone() is None:
            raise HTTPException(status_code=404, detail="Character not found")

        hp, quantity = consume_item(cur, body.character_id, body.item_id)
    return UseResult(hp=hp, quantity=quantity)
