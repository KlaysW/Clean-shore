from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import get_current_user
from app.core.config import settings
from app.core.database import get_db
from app.models.pollution_spot import PollutionSpot, SpotStatus
from app.models.user import User
from app.schemas.spot import HeatmapPoint, SpotRead
from app.schemas.user import LeaderboardEntry, UserPublic
from app.services import spatial_service

router = APIRouter(tags=["Map & Leaderboard"])


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


@router.get("/map/spots", response_model=list[SpotRead])
async def list_spots(
    status_filter: str | None = Query(default=None, alias="status"),
    db: AsyncSession = Depends(get_db),
    _current_user: User = Depends(get_current_user),
) -> list[SpotRead]:
    spots = await spatial_service.get_heatmap_spots(db, status_filter=status_filter)
    return [_to_spot_read(s) for s in spots]


@router.get("/map/heatmap", response_model=list[HeatmapPoint])
async def get_heatmap(
    db: AsyncSession = Depends(get_db),
    _current_user: User = Depends(get_current_user),
) -> list[HeatmapPoint]:
    spots = await spatial_service.get_heatmap_spots(db)
    points: list[HeatmapPoint] = []

    for spot in spots:
        lat, lon = spatial_service.extract_lat_lon(spot)
        weight = (spot.pollution_score_before or 0) / 100
        points.append(
            HeatmapPoint(
                lat=lat,
                lon=lon,
                weight=weight,
                status=spot.status,
                spot_id=spot.id,
            )
        )

    return points


@router.get("/leaderboard", response_model=list[LeaderboardEntry])
async def get_leaderboard(
    region: str | None = Query(default=None),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[LeaderboardEntry]:
    stmt = select(User)
    if region:
        stmt = stmt.where(User.region == region)
    
    stmt = stmt.order_by(User.rating_points.desc()).limit(settings.LEADERBOARD_TOP_SIZE)

    result = await db.execute(stmt)
    users = list(result.scalars().all())

    entries: list[LeaderboardEntry] = []
    for idx, user in enumerate(users, start=1):
        points_to_next = None
        if idx > 1:
            points_to_next = users[idx - 2].rating_points - user.rating_points

        entries.append(
            LeaderboardEntry(
                rank=idx,
                user=UserPublic.model_validate(user),
                points_to_next_rank=points_to_next,
            )
        )

    return entries