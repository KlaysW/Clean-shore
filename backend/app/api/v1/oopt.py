from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import get_current_oopt_user, get_current_user
from app.core.database import get_db
from app.models.pollution_spot import PollutionSpot, SpotStatus
from app.models.user import User
from app.schemas.spot import SpotRead
from app.schemas.user import UserPublic
from app.services import spatial_service

router = APIRouter(prefix="/oopt", tags=["OOPT Professional Mode"])


def _to_spot_read(spot: PollutionSpot) -> SpotRead:
    lat, lon = spatial_service.extract_lat_lon(spot)
    return SpotRead(
        id=spot.id,
        reporter_id=spot.reporter_id,
        cleaner_id=spot.cleaner_id,
        lat=lat,
        lon=lon,
        pollution_score_before=spot.pollution_score_before,
        pollution_score_after=spot.pollution_score_after,
        detected_materials=spot.detected_materials,
        photo_before_url=spot.photo_before_url,
        photo_after_url=spot.photo_after_url,
        status=spot.status,
        created_at=spot.created_at,
        updated_at=spot.updated_at,
    )


@router.get("/dashboard/priority-spots", response_model=list[SpotRead])
async def get_priority_spots(
    db: AsyncSession = Depends(get_db),
    _oopt_user: User = Depends(get_current_oopt_user),
) -> list[SpotRead]:
    stmt = (
        select(PollutionSpot)
        .where(PollutionSpot.status == SpotStatus.ACTIVE)
        .order_by(PollutionSpot.pollution_score_before.desc())
        .limit(100)
    )
    result = await db.execute(stmt)
    spots = list(result.scalars().all())
    return [_to_spot_read(s) for s in spots]


@router.get("/dashboard/verified-inspectors", response_model=list[UserPublic])
async def get_verified_inspectors(
    db: AsyncSession = Depends(get_db),
    _oopt_user: User = Depends(get_current_oopt_user),
) -> list[UserPublic]:
    stmt = select(User).where(User.is_oopt_staff.is_(True))
    result = await db.execute(stmt)
    inspectors = list(result.scalars().all())
    return [UserPublic.model_validate(i) for i in inspectors]


@router.post("/apply", status_code=204)
async def apply_for_oopt_access(
    _current_user: User = Depends(get_current_user),
) -> None:
    return None