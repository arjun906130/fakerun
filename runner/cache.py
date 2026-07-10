"""
cache.py â€” Leaderboard caching utilities.

Uses Django's low-level cache API to avoid hitting the database
on every leaderboard request. The cache is invalidated automatically
whenever a new score is submitted.
"""

from django.core.cache import cache

LEADERBOARD_CACHE_KEY = "runner:leaderboard:top15"
LEADERBOARD_CACHE_TTL = 60  # seconds


def get_cached_leaderboard(difficulty=None):
    """
    Returns the cached leaderboard list for the specified difficulty scope,
    or None if the cache has expired or has not been populated yet.
    """
    key = LEADERBOARD_CACHE_KEY
    if difficulty:
        key = f"{key}:{difficulty}"
    return cache.get(key)


def set_cached_leaderboard(data, difficulty=None):
    """
    Stores the leaderboard data in the cache with the configured TTL.

    Args:
        data: A list of leaderboard entry dicts to cache.
        difficulty: Optional difficulty string filter scope.
    """
    key = LEADERBOARD_CACHE_KEY
    if difficulty:
        key = f"{key}:{difficulty}"
    cache.set(key, data, timeout=LEADERBOARD_CACHE_TTL)


def invalidate_leaderboard_cache():
    """
    Deletes all cached leaderboard variations, forcing the next request
    to re-query the database.
    Call this after any new Score record is created.
    """
    cache.delete(LEADERBOARD_CACHE_KEY)
    for diff in ['easy', 'medium', 'hard']:
        cache.delete(f"{LEADERBOARD_CACHE_KEY}:{diff}")

