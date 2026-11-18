from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/demo", tags=["demo"])


@router.get("")
def seed_demo_data():
    raise HTTPException(status_code=501, detail="Not implemented")
