from typing import Literal

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from ..db import transaction
from ..security import get_current_user
from .inventory import consume_item

router = APIRouter(prefix="/combat", tags=["combat"])

MANA_COST = 5

BATTLE_STATE = """
    SELECT b.battle_id, b.character_id, b.enemy_id, b.enemy_hp, b.character_hp,
           b.character_mana, b.turn, b.finished_at, b.outcome,
           c.melee, c.ranged, c.armor, c.max_hp,
           e.melee AS enemy_melee, e.ranged AS enemy_ranged, e.armor AS enemy_armor
    FROM battles b
    JOIN characters c ON c.character_id = b.character_id
    JOIN enemies e ON e.enemy_id = b.enemy_id
"""


class BattleStart(BaseModel):
    character_id: int
    enemy_id: int


class BattleAction(BaseModel):
    kind: Literal["attack_a", "attack_b", "item"]
    item_id: int | None = None


class Battle(BaseModel):
    battle_id: int
    character_id: int
    enemy_id: int
    enemy_hp: int
    character_hp: int
    character_mana: int
    turn: int
    finished: bool
    outcome: Literal["win", "loss", "fled"] | None


def _state(row, finished: bool, outcome: str | None) -> Battle:
    return Battle(
        battle_id=row["battle_id"],
        character_id=row["character_id"],
        enemy_id=row["enemy_id"],
        enemy_hp=row["enemy_hp"],
        character_hp=row["character_hp"],
        character_mana=row["character_mana"],
        turn=row["turn"],
        finished=finished,
        outcome=outcome,
    )


@router.post("/start", response_model=Battle)
def start_battle(body: BattleStart, user_id: int = Depends(get_current_user)):
    with transaction() as cur:
        cur.execute(
            "SELECT hp, mana FROM characters WHERE character_id = %s AND user_id = %s",
            (body.character_id, user_id),
        )
        character = cur.fetchone()
        if character is None:
            raise HTTPException(status_code=404, detail="Character not found")

        cur.execute("SELECT hp FROM enemies WHERE enemy_id = %s", (body.enemy_id,))
        enemy = cur.fetchone()
        if enemy is None:
            raise HTTPException(status_code=404, detail="Enemy not found")

        cur.execute(
            "INSERT INTO battles "
            "(character_id, enemy_id, enemy_hp, character_hp, character_mana, started_at) "
            "VALUES (%s, %s, %s, %s, %s, NOW())",
            (body.character_id, body.enemy_id, enemy["hp"], character["hp"], character["mana"]),
        )
        battle_id = cur.lastrowid

    return Battle(
        battle_id=battle_id,
        character_id=body.character_id,
        enemy_id=body.enemy_id,
        enemy_hp=enemy["hp"],
        character_hp=character["hp"],
        character_mana=character["mana"],
        turn=0,
        finished=False,
        outcome=None,
    )


@router.post("/{battle_id}/action", response_model=Battle)
def battle_action(battle_id: int, body: BattleAction, user_id: int = Depends(get_current_user)):
    with transaction() as cur:
        cur.execute(BATTLE_STATE + " WHERE b.battle_id = %s AND c.user_id = %s FOR UPDATE", (battle_id, user_id))
        row = cur.fetchone()
        if row is None:
            raise HTTPException(status_code=404, detail="Battle not found")
        if row["finished_at"] is not None:
            raise HTTPException(status_code=400, detail="Battle already finished")

        enemy_hp = row["enemy_hp"]
        character_hp = row["character_hp"]
        mana = row["character_mana"]

        if body.kind == "item":
            if body.item_id is None:
                raise HTTPException(status_code=400, detail="item_id is required")
            character_hp, _ = consume_item(cur, row["character_id"], body.item_id)
        else:
            if body.kind == "attack_a":
                damage = max(1, row["melee"] - row["enemy_armor"] // 2)
            else:
                if mana < MANA_COST:
                    raise HTTPException(status_code=400, detail="Not enough mana")
                mana -= MANA_COST
                damage = max(1, row["ranged"] - row["enemy_armor"] // 2)
            enemy_hp = max(0, enemy_hp - damage)

        outcome = None
        if enemy_hp == 0:
            outcome = "win"
        else:
            enemy_damage = max(1, max(row["enemy_melee"], row["enemy_ranged"]) - row["armor"] // 2)
            character_hp = max(0, character_hp - enemy_damage)
            if character_hp == 0:
                outcome = "loss"

        turn = row["turn"] + 1
        cur.execute(
            "UPDATE battles SET enemy_hp = %s, character_hp = %s, character_mana = %s, turn = %s "
            "WHERE battle_id = %s",
            (enemy_hp, character_hp, mana, turn, battle_id),
        )
        cur.execute(
            "UPDATE characters SET hp = %s, mana = %s WHERE character_id = %s",
            (character_hp, mana, row["character_id"]),
        )
        if outcome is not None:
            cur.execute("CALL sp_settle_battle(%s, %s)", (battle_id, outcome))

    return _state(
        dict(row, enemy_hp=enemy_hp, character_hp=character_hp, character_mana=mana, turn=turn),
        finished=outcome is not None,
        outcome=outcome,
    )


@router.post("/{battle_id}/flee", response_model=Battle)
def flee_battle(battle_id: int, user_id: int = Depends(get_current_user)):
    with transaction() as cur:
        cur.execute(BATTLE_STATE + " WHERE b.battle_id = %s AND c.user_id = %s FOR UPDATE", (battle_id, user_id))
        row = cur.fetchone()
        if row is None:
            raise HTTPException(status_code=404, detail="Battle not found")
        if row["finished_at"] is not None:
            raise HTTPException(status_code=400, detail="Battle already finished")

        cur.execute("CALL sp_settle_battle(%s, 'fled')", (battle_id,))

    return _state(row, finished=True, outcome="fled")
