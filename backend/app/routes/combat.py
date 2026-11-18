from typing import Literal

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from ..security import get_current_user

router = APIRouter(prefix="/combat", tags=["combat"])


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


@router.post("/start", response_model=Battle)
def start_battle(body: BattleStart, user_id: int = Depends(get_current_user)):
    raise HTTPException(status_code=501, detail="Not implemented")


@router.post("/{battle_id}/action", response_model=Battle)
def battle_action(battle_id: int, body: BattleAction, user_id: int = Depends(get_current_user)):
    raise HTTPException(status_code=501, detail="Not implemented")


@router.post("/{battle_id}/flee", response_model=Battle)
def flee_battle(battle_id: int, user_id: int = Depends(get_current_user)):
    raise HTTPException(status_code=501, detail="Not implemented")
