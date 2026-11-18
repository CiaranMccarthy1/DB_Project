from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

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


@router.get("", response_model=list[InventoryItem])
def list_inventory(user_id: int = Depends(get_current_user)):
    raise HTTPException(status_code=501, detail="Not implemented")


@router.post("/use", response_model=UseResult)
def use_item(body: UseItem, user_id: int = Depends(get_current_user)):
    raise HTTPException(status_code=501, detail="Not implemented")
