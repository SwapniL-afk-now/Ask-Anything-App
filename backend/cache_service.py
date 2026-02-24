"""Cache service for storing and retrieving analysis results."""
import hashlib
import json
from typing import Optional, Any
from datetime import datetime, timedelta
from aiocache import Cache
from aiocache.serializers import BaseSerializer
import os


class JSONSerializer(BaseSerializer):
    """Custom JSON serializer for cache."""

    def dumps(self, value: Any) -> str:
        return json.dumps(value, default=str)

    def loads(self, value: str) -> Any:
        if value is None:
            return None
        return json.loads(value)


class CacheService:
    """Service for caching analysis results with TTL support."""

    def __init__(self):
        self.cache = Cache(
            Cache.MEMORY,
            ttl=int(os.getenv("CACHE_TTL_SECONDS", 3600)),
            serializer=JSONSerializer()
        )

    @staticmethod
    def generate_cache_key(profession: str, topic: str) -> str:
        """Generate a unique cache key based on profession and topic."""
        normalized_profession = profession.lower().strip()
        normalized_topic = topic.lower().strip()
        combined = f"{normalized_profession}:{normalized_topic}"
        return hashlib.sha256(combined.encode()).hexdigest()[:32]

    async def get(self, profession: str, topic: str) -> Optional[dict]:
        """Retrieve cached analysis result."""
        key = self.generate_cache_key(profession, topic)
        return await self.cache.get(key)

    async def set(self, profession: str, topic: str, data: dict) -> None:
        """Store analysis result in cache."""
        key = self.generate_cache_key(profession, topic)
        await self.cache.set(key, data)

    async def delete(self, profession: str, topic: str) -> bool:
        """Delete cached analysis result."""
        key = self.generate_cache_key(profession, topic)
        return await self.cache.delete(key)

    async def clear_all(self) -> None:
        """Clear all cached entries."""
        await self.cache.clear()


# Global cache instance
cache_service = CacheService()
