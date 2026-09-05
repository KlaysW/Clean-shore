from fastapi import APIRouter, Depends, HTTPException, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import get_current_user
from app.core.config import settings
from app.core.database import get_db
from app.models.pollution_spot import PollutionSpot, SpotStatus
from app.models.user import User
from app.schemas.spot import (
    PhotoUploadResponse,
    SpotCleanupRequest,
    SpotCleanupResult,
    SpotRead,
    SpotSearchRequest,
    SpotSearchResult,
)
from app.services import spatial_service
from app.services.s3_service import s3_service
from app.services.vision_service import VisionServiceError, vision_service

router = APIRouter(prefix="/quests", tags=["Quests"])

ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_UPLOAD_SIZE_BYTES = 10 * 1024 * 1024


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


def _calculate_search_rating(contamination_level: int) -> int:
    span = settings.RATING_SEARCH_MAX - settings.RATING_SEARCH_MIN
    return settings.RATING_SEARCH_MIN + round((contamination_level / 100) * span)


def _calculate_cleanup_rating(contamination_delta: int) -> int:
    span = settings.RATING_CLEANUP_MAX - settings.RATING_CLEANUP_MIN
    ratio = min(max(contamination_delta / 100, 0), 1)
    return settings.RATING_CLEANUP_MIN + round(ratio * span)


@router.post("/upload-photo", response_model=PhotoUploadResponse, status_code=status.HTTP_201_CREATED)
async def upload_photo(
    file: UploadFile,
    _current_user: User = Depends(get_current_user),
) -> PhotoUploadResponse:
    if file.content_type not in ALLOWED_CONTENT_TYPES:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail="Допустимые форматы: JPEG, PNG, WEBP",
        )

    content = await file.read()

    if len(content) > MAX_UPLOAD_SIZE_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Максимальный размер файла — 10 МБ",
        )

    url = await s3_service.upload_photo(
        content=content,
        filename=file.filename or "photo.jpg",
        content_type=file.content_type,
        folder="spots",
    )

    return PhotoUploadResponse(url=url)


@router.post("/search", response_model=SpotSearchResult, status_code=status.HTTP_201_CREATED)
async def pollution_search(
    payload: SpotSearchRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> SpotSearchResult:
    duplicate_check = await spatial_service.find_nearby_active_spot(
        db, lat=payload.lat, lon=payload.lon
    )

    if duplicate_check.is_duplicate:
        return SpotSearchResult(
            spot=_to_spot_read(duplicate_check.spot),
            rating_awarded=0,
            is_duplicate=True,
            duplicate_distance_m=duplicate_check.distance_m,
        )

    try:
        vision_result = await vision_service.analyze_image(payload.photo_url)
    except VisionServiceError as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Ошибка анализа изображения: {exc}",
        ) from exc

    new_spot = PollutionSpot(
        reporter_id=current_user.id,
        location=spatial_service.make_point_wkt(payload.lat, payload.lon),
        pollution_score_before=vision_result.contamination_level,
        detected_materials=vision_result.materials,
        photo_before_url=payload.photo_url,
        status=SpotStatus.ACTIVE,
    )
    db.add(new_spot)

    rating_awarded = _calculate_search_rating(vision_result.contamination_level)
    current_user.rating_points += rating_awarded
    current_user.spots_found_count += 1

    await db.commit()

    spot_read = SpotRead(
        id=new_spot.id,
        reporter_id=new_spot.reporter_id,
        cleaner_id=new_spot.cleaner_id,
        lat=payload.lat,
        lon=payload.lon,
        pollution_score_before=new_spot.pollution_score_before,
        pollution_score_after=new_spot.pollution_score_after,
        detected_materials=new_spot.detected_materials,
        photo_before_url=new_spot.photo_before_url,
        photo_after_url=new_spot.photo_after_url,
        status=new_spot.status,
        created_at=new_spot.created_at,
        updated_at=new_spot.updated_at,
    )

    return SpotSearchResult(
        spot=spot_read,
        rating_awarded=rating_awarded,
        is_duplicate=False,
        duplicate_distance_m=None,
    )


@router.post("/cleanup", response_model=SpotCleanupResult)
async def pollution_cleanup(
    payload: SpotCleanupRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> SpotCleanupResult:
    spot = await spatial_service.get_spot_by_id(db, payload.spot_id)

    if spot is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Точка загрязнения не найдена"
        )

    if spot.status == SpotStatus.CLEANED:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Эта точка уже отмечена как очищенная",
        )

    try:
        vision_result = await vision_service.analyze_image(
            payload.photo_after_url, context_hint="Фото 'после уборки', сравни с исходным уровнем загрязнения"
        )
    except VisionServiceError as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Ошибка анализа изображения: {exc}",
        ) from exc

    before_score = spot.pollution_score_before or 0
    after_score = vision_result.contamination_level
    contamination_delta = max(before_score - after_score, 0)

    spot.pollution_score_after = after_score
    spot.photo_after_url = payload.photo_after_url
    spot.cleaner_id = current_user.id
    spot.status = SpotStatus.CLEANED

    rating_awarded = _calculate_cleanup_rating(contamination_delta)
    current_user.rating_points += rating_awarded
    current_user.spots_cleaned_count += 1

    await db.commit()
    await db.refresh(spot)

    return SpotCleanupResult(
        spot=_to_spot_read(spot),
        rating_awarded=rating_awarded,
        contamination_delta=contamination_delta,
    )