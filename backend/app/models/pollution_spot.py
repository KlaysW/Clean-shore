import uuid
from datetime import datetime

from geoalchemy2 import Geometry
from sqlalchemy import ARRAY, DateTime, ForeignKey, Integer, String, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class SpotStatus:
    ACTIVE = "ACTIVE"
    IN_PROGRESS = "IN_PROGRESS"
    CLEANED = "CLEANED"


class PollutionSpot(Base):
    __tablename__ = "pollution_spots"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )

    reporter_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=True
    )
    cleaner_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id"), nullable=True
    )

    location: Mapped[str] = mapped_column(
        Geometry(geometry_type="POINT", srid=4326), nullable=False
    )

    pollution_score_before: Mapped[int | None] = mapped_column(Integer, nullable=True)
    pollution_score_after: Mapped[int | None] = mapped_column(Integer, nullable=True)
    detected_materials: Mapped[list[str] | None] = mapped_column(
        ARRAY(String), nullable=True
    )

    photo_before_url: Mapped[str] = mapped_column(String, nullable=False)
    photo_after_url: Mapped[str | None] = mapped_column(String, nullable=True)

    status: Mapped[str] = mapped_column(String(50), default=SpotStatus.ACTIVE)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    reporter = relationship(
        "User", foreign_keys=[reporter_id], back_populates="reported_spots"
    )
    cleaner = relationship(
        "User", foreign_keys=[cleaner_id], back_populates="cleaned_spots"
    )