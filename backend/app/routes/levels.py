from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter(prefix="/levels", tags=["levels"])


class Chapter(BaseModel):
    chapter_id: int
    chapter_name: str


@router.get("", response_model=list[Chapter])
def list_chapters():
    raise HTTPException(status_code=501, detail="Not implemented")


@router.get("/{chapter_id}", response_model=Chapter)
def get_chapter(chapter_id: int):
    raise HTTPException(status_code=501, detail="Not implemented")
