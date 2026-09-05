import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UserBase(BaseModel):
    email: str = Field(min_length=5, max_length=255)
    nickname: str = Field(min_length=2, max_length=100)


class UserCreate(UserBase):
    password: str = Field(min_length=8, max_length=128)
    is_oopt_staff: bool = False


class UserLogin(BaseModel):
    email: str
    password: str


class UserRead(UserBase):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    rating_points: int
    region: str
    is_oopt_staff: bool
    avatar_url: str | None = None
    spots_found_count: int
    spots_cleaned_count: int
    created_at: datetime


class UserPublic(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    nickname: str
    rating_points: int
    region: str
    avatar_url: str | None = None
    spots_found_count: int
    spots_cleaned_count: int


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class LeaderboardEntry(BaseModel):
    rank: int
    user: UserPublic
    points_to_next_rank: int | None = None