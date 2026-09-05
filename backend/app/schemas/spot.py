import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class GeoPoint(BaseModel):
    lat: float = Field(ge=-90, le=90)
    lon: float = Field(ge=-180, le=180)


class SpotSearchRequest(BaseModel):
    lat: float = Field(ge=-90, le=90)
    lon: float = Field(ge=-180, le=180)
    photo_url: str


class SpotCleanupRequest(BaseModel):
    spot_id: uuid.UUID
    photo_after_url: str


class SpotRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    reporter_id: uuid.UUID | None = None
    cleaner_id: uuid.UUID | None = None
    lat: float
    lon: float
    pollution_score_before: int | None = None
    pollution_score_after: int | None = None
    detected_materials: list[str] | None = None
    photo_before_url: str
    photo_after_url: str | None = None
    status: str
    created_at: datetime
    updated_at: datetime


class SpotSearchResult(BaseModel):
    spot: SpotRead
    rating_awarded: int
    is_duplicate: bool
    duplicate_distance_m: float | None = None


class SpotCleanupResult(BaseModel):
    spot: SpotRead
    rating_awarded: int
    contamination_delta: int


class HeatmapPoint(BaseModel):
    lat: float
    lon: float
    weight: float
    status: str
    spot_id: uuid.UUID


class PhotoUploadResponse(BaseModel):
    url: str