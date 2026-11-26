from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from ..db import transaction

router = APIRouter(prefix="/levels", tags=["levels"])


class Chapter(BaseModel):
    chapter_id: int
    chapter_name: str


@router.get("", response_model=list[Chapter])
def list_chapters():
    with transaction() as cur:
        cur.execute("SELECT chapter_id, chapter_name FROM chapters ORDER BY chapter_id")
        return [Chapter(**row) for row in cur.fetchall()]


@router.get("/{chapter_id}", response_model=Chapter)
def get_chapter(chapter_id: int):
    with transaction() as cur:
        cur.execute(
            "SELECT chapter_id, chapter_name FROM chapters WHERE chapter_id = %s",
            (chapter_id,),
        )
        row = cur.fetchone()
    if row is None:
        raise HTTPException(status_code=404, detail="Chapter not found")
    return Chapter(**row)
