import asyncio
import uuid
from datetime import datetime, timezone

import boto3
from botocore.client import Config

from app.core.config import settings


class S3Service:
    def __init__(self) -> None:
        self._client = boto3.client(
            "s3",
            endpoint_url=settings.S3_ENDPOINT_URL,
            aws_access_key_id=settings.S3_ACCESS_KEY,
            aws_secret_access_key=settings.S3_SECRET_KEY,
            region_name=settings.S3_REGION,
            config=Config(signature_version="s3v4"),
        )
        self._bucket = settings.S3_BUCKET_NAME

    def _build_key(self, folder: str, filename: str) -> str:
        date_prefix = datetime.now(timezone.utc).strftime("%Y/%m/%d")
        ext = filename.rsplit(".", 1)[-1] if "." in filename else "jpg"
        unique_name = f"{uuid.uuid4().hex}.{ext}"
        return f"{folder}/{date_prefix}/{unique_name}"

    def _put_object_sync(self, key: str, content: bytes, content_type: str) -> str:
        if not settings.S3_ACCESS_KEY:
            return f"https://placeholder.clean-shore.local/{key}"

        self._client.put_object(
            Bucket=self._bucket,
            Key=key,
            Body=content,
            ContentType=content_type,
        )
        return f"{settings.S3_PUBLIC_URL_BASE.rstrip('/')}/{key}"

    async def upload_photo(
        self,
        content: bytes,
        filename: str,
        content_type: str = "image/jpeg",
        folder: str = "spots",
    ) -> str:
        key = self._build_key(folder, filename)
        return await asyncio.to_thread(
            self._put_object_sync, key, content, content_type
        )

    def _delete_object_sync(self, key: str) -> None:
        self._client.delete_object(Bucket=self._bucket, Key=key)

    async def delete_photo(self, url: str) -> None:
        key = url.replace(f"{settings.S3_PUBLIC_URL_BASE}/", "")
        await asyncio.to_thread(self._delete_object_sync, key)


s3_service = S3Service()