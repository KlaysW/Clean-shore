import uuid

from geoalchemy2.functions import ST_DistanceSphere, ST_DWithin, ST_MakePoint, ST_SetSRID, ST_X, ST_Y
from geoalchemy2.types import Geography
from sqlalchemy import cast, select

from app.core.config import settings
from app.models.pollution_spot import PollutionSpot, SpotStatus


def make_point_wkt(lat: float, lon: float) -> str:
    return f"SRID=4326;POINT({lon} {lat})"


def extract_lat_lon(spot: PollutionSpot) -> tuple[float, float]:
    from geoalchemy2.shape import to_shape

    point = to_shape(spot.location)
    return point.y, point.x


class DuplicateSpotResult:
    def __init__(self, spot: PollutionSpot | None, distance_m: float | None):
        self.spot = spot
        self.distance_m = distance_m

    @property
    def is_duplicate(self) -> bool:
        return self.spot is not None


async def find_nearby_active_spot(
    db: AsyncSession,
    lat: float,
    lon: float,
    radius_meters: float | None = None,
) -> DuplicateSpotResult:
    radius = radius_meters or settings.SPATIAL_DEDUP_RADIUS_METERS
    target_point = ST_SetSRID(ST_MakePoint(lon, lat), 4326)

    stmt = (
        select(
            PollutionSpot,
            ST_DistanceSphere(PollutionSpot.location, target_point).label("distance"),
        )
        .where(
            ST_DWithin(
                cast(PollutionSpot.location, Geography),
                cast(target_point, Geography),
                radius,
            ),
            PollutionSpot.status == SpotStatus.ACTIVE,
        )
        .order_by("distance")
        .limit(1)
    )

    result = await db.execute(stmt)
    row = result.first()

    if row is None:
        return DuplicateSpotResult(spot=None, distance_m=None)

    spot, distance = row
    return DuplicateSpotResult(spot=spot, distance_m=float(distance))


async def get_spot_by_id(db: AsyncSession, spot_id: uuid.UUID) -> PollutionSpot | None:
    result = await db.execute(select(PollutionSpot).where(PollutionSpot.id == spot_id))
    return result.scalar_one_or_none()


async def get_heatmap_spots(
    db: AsyncSession, status_filter: str | None = None
) -> list[PollutionSpot]:
    stmt = select(PollutionSpot)
    if status_filter:
        stmt = stmt.where(PollutionSpot.status == status_filter)
    result = await db.execute(stmt)
    return list(result.scalars().all())