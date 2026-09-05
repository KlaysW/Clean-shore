import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Integer, String, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    nickname: Mapped[str] = mapped_column(String(100), nullable=False)

    rating_points: Mapped[int] = mapped_column(Integer, default=0)
    region: Mapped[str] = mapped_column(String(100), default="Main Region")
    is_oopt_staff: Mapped[bool] = mapped_column(Boolean, default=False)

    avatar_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    spots_found_count: Mapped[int] = mapped_column(Integer, default=0)
    spots_cleaned_count: Mapped[int] = mapped_column(Integer, default=0)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    reported_spots = relationship(
        "PollutionSpot",
        foreign_keys="PollutionSpot.reporter_id",
        back_populates="reporter",
    )
    cleaned_spots = relationship(
        "PollutionSpot",
        foreign_keys="PollutionSpot.cleaner_id",
        back_populates="cleaner",
    )