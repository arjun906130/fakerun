"""
game_filters.py
Custom Django template filters for the CLUTCH RUN game templates.

Registration:
    {% load game_filters %}
"""

from django import template
from runner.utils import calculate_rating, format_score

register = template.Library()


@register.filter(name="format_score")
def format_score_filter(value):
    """
    Formats an integer score with comma separators.
    Usage: {{ player.best_score|format_score }}
    """
    try:
        return format_score(int(value))
    except (ValueError, TypeError):
        return value


@register.filter(name="rating")
def rating_filter(value):
    """
    Converts a numeric score to a letter rating (S/A/B/C/D).
    Usage: {{ player.best_score|rating }}
    """
    try:
        return calculate_rating(int(value))
    except (ValueError, TypeError):
        return "D"


@register.filter(name="rank_badge")
def rank_badge_filter(rank):
    """
    Returns a medal emoji for the top 3 leaderboard positions.
    Usage: {{ forloop.counter|rank_badge }}
    """
    badges = {1: "ðŸ¥‡", 2: "ðŸ¥ˆ", 3: "ðŸ¥‰"}
    return badges.get(rank, str(rank))
