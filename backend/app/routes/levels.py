from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from ..db import transaction

router = APIRouter(prefix="/levels", tags=["levels"])

TILE_CHARS = {"wall": "#", "floor": ".", "spawn": "P", "door": "D"}


class Chapter(BaseModel):
    chapter_id: int
    chapter_name: str


class LevelMap(BaseModel):
    level_id: int
    level_name: str
    width: int
    height: int
    rows: list[str]


@router.get("/{level_id}/tiles", response_model=LevelMap)
def get_level_tiles(level_id: int):
    with transaction() as cur:
        cur.execute(
            "SELECT level_name, width, height FROM levels WHERE level_id = %s",
            (level_id,),
        )
        level = cur.fetchone()
        if level is None:
            raise HTTPException(status_code=404, detail="Level not found")
        cur.execute(
            "SELECT pos_x, pos_y, tile_kind FROM level_tiles "
            "WHERE level_id = %s ORDER BY pos_y, pos_x",
            (level_id,),
        )
        tiles = cur.fetchall()

    # missing tiles default to wall so the map can never have holes
    grid = [["#"] * level["width"] for _ in range(level["height"])]
    for tile in tiles:
        grid[tile["pos_y"]][tile["pos_x"]] = TILE_CHARS.get(tile["tile_kind"], ".")
    return LevelMap(
        level_id=level_id,
        level_name=level["level_name"],
        width=level["width"],
        height=level["height"],
        rows=["".join(row) for row in grid],
    )


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
