from functools import lru_cache
from typing import List

from pydantic import Field, PostgresDsn, AnyHttpUrl, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )

    PROJECT_NAME: str = "Clean Shore | Чистый берег"
    API_V1_PREFIX: str = "/api/v1"
    ENVIRONMENT: str = Field(default="development")
    DEBUG: bool = Field(default=True)

    BACKEND_CORS_ORIGINS: List[str] = Field(
        default_factory=lambda: [
            "http://localhost:5173",
            "http://localhost:3000",
            "https://clean-shore.example.com",
        ]
    )

    @field_validator("BACKEND_CORS_ORIGINS", mode="before")
    @classmethod
    def assemble_cors_origins(cls, v):
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        return v

    POSTGRES_USER: str = Field(default="clean_shore")
    POSTGRES_PASSWORD: str = Field(default="clean_shore_pass")
    POSTGRES_SERVER: str = Field(default="localhost")
    POSTGRES_PORT: int = Field(default=5432)
    POSTGRES_DB: str = Field(default="clean_shore_db")

    DATABASE_URL: str | None = Field(default=None)

    @property
    def ALEMBIC_DATABASE_URI(self) -> str:
        return self.SQLALCHEMY_DATABASE_URI

    @property
    def ALEMBIC_DATABASE_URI(self) -> str:
        if self.DATABASE_URL:
            return self.DATABASE_URL.replace("+asyncpg", "")
        return (
            f"postgresql+psycopg2://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_SERVER}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )

    SECRET_KEY: str = Field(default="CHANGE_ME_super_secret_key_for_hackathon_demo")
    JWT_ALGORITHM: str = Field(default="HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=60 * 24 * 7)  # 7 days

    OPENROUTER_API_KEY: str = Field(default="")
    OPENROUTER_BASE_URL: str = Field(default="https://openrouter.ai/api/v1")
    OPENROUTER_VISION_MODEL: str = Field(default="openai/gpt-4o")
    OPENROUTER_LLM_MODEL: str = Field(default="anthropic/claude-3.5-sonnet")
    OPENROUTER_HTTP_REFERER: str = Field(default="https://clean-shore.example.com")
    OPENROUTER_APP_TITLE: str = Field(default="Clean Shore Eco Platform")

    S3_ENDPOINT_URL: str = Field(default="https://storage.yandexcloud.net")
    S3_ACCESS_KEY: str = Field(default="")
    S3_SECRET_KEY: str = Field(default="")
    S3_BUCKET_NAME: str = Field(default="clean-shore-media")
    S3_REGION: str = Field(default="ru-central1")
    S3_PUBLIC_URL_BASE: str = Field(
        default="https://storage.yandexcloud.net/clean-shore-media"
    )

    SPATIAL_DEDUP_RADIUS_METERS: float = Field(default=15.0)
    RATING_SEARCH_MIN: int = Field(default=50)
    RATING_SEARCH_MAX: int = Field(default=250)
    RATING_CLEANUP_MIN: int = Field(default=200)
    RATING_CLEANUP_MAX: int = Field(default=2000)
    LEADERBOARD_TOP_SIZE: int = Field(default=50)


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()