"""
cache.py â€” Leaderboard caching utilities.

Uses Django's low-level cache API to avoid hitting the database
on every leaderboard request. The cache is invalidated automatically
whenever a new score is submitted.
"""

from django.core.cache import cache

LEADERBOARD_CACHE_KEY = "runner:leaderboard:top15"
LEADERBOARD_CACHE_TTL = 60  # seconds


def get_cached_leaderboard():
    """
    Returns the cached leaderboard list, or None if the cache has expired
    or has not been populated yet.
    """
    return cache.get(LEADERBOARD_CACHE_KEY)


def set_cached_leaderboard(data):
    """
    Stores the leaderboard data in the cache with the configured TTL.

    Args:
        data: A list of leaderboard entry dicts to cache.
    """
    cache.set(LEADERBOARD_CACHE_KEY, data, timeout=LEADERBOARD_CACHE_TTL)


def invalidate_leaderboard_cache():
    """
    Deletes the cached leaderboard entry, forcing the next request
    to re-query the database.
    Call this after any new Score record is created.
    """
    cache.delete(LEADERBOARD_CACHE_KEY)
