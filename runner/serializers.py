"""
serializers.py â€” Lightweight dict serializers for runner model instances.

These serializers convert model objects into plain Python dicts suitable
for JSON responses, following a pattern similar to DRF serializers but
without the external dependency.
"""

from .utils import format_score, calculate_rating


def serialize_score(score, rank=None):
    """
    Serializes a Score model instance to a dict for API responses.

    Args:
        score: A Score model instance.
        rank:  Optional integer rank position for leaderboard display.

    Returns:
        A dict with username, score, timestamp, rating, and optionally rank.
    """
    data = {
        "username":        score.player.username,
        "score":           score.score,
        "formatted_score": format_score(score.score),
        "rating":          calculate_rating(score.score),
        "timestamp":       score.timestamp.strftime("%Y-%m-%d %H:%M"),
    }
    if rank is not None:
        data["rank"] = rank
    return data


def serialize_player(player):
    """
    Serializes a Player model instance to a dict for API responses.

    Args:
        player: A Player model instance.

    Returns:
        A dict with username, best score, total runs, average score, and member_since.
    """
    return {
        "username":        player.username,
        "best_score":      player.best_score,
        "formatted_best":  format_score(player.best_score),
        "rating":          calculate_rating(player.best_score),
        "total_runs":      player.total_runs,
        "average_score":   player.average_score,
        "longest_streak":  player.longest_streak,
        "current_streak":  player.current_streak,
        "member_since":    player.created_at.strftime("%Y-%m-%d"),
    }
