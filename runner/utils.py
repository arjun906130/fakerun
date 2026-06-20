"""
utils.py
--------
Shared utility helpers for the runner application.
Keep this module free of Django model imports to avoid circular imports.
"""

import re
from datetime import datetime


# ---------------------------------------------------------------------------
# Username validation
# ---------------------------------------------------------------------------

USERNAME_PATTERN = re.compile(r'^[A-Z0-9_]{2,12}$')


def is_valid_username(value: str) -> bool:
    """
    Validates a player username against the game's naming rules:
      - 2 to 12 characters long
      - Only uppercase letters (A-Z), digits (0-9), and underscores (_)

    Args:
        value: The raw username string to validate.

    Returns:
        True if the username is valid, False otherwise.
    """
    if not isinstance(value, str):
        return False
    return bool(USERNAME_PATTERN.match(value.strip()))


# ---------------------------------------------------------------------------
# Score helpers
# ---------------------------------------------------------------------------

def calculate_rating(score: int) -> str:
    """
    Converts a numeric score into a letter-grade performance rating.

    Rating thresholds:
        S  — 50,000+
        A  — 25,000+
        B  — 10,000+
        C  — 5,000+
        D  — below 5,000

    Args:
        score: The player's final score (non-negative integer).

    Returns:
        A single-character rating string ('S', 'A', 'B', 'C', or 'D').
    """
    if score >= 50_000:
        return 'S'
    elif score >= 25_000:
        return 'A'
    elif score >= 10_000:
        return 'B'
    elif score >= 5_000:
        return 'C'
    return 'D'


def format_score(score: int) -> str:
    """
    Formats a score integer with comma separators for display.

    Args:
        score: Integer score value.

    Returns:
        A formatted string, e.g. 1234567 → '1,234,567'.
    """
    return f"{score:,}"


# ---------------------------------------------------------------------------
# Timestamp helpers
# ---------------------------------------------------------------------------

def utc_now_formatted() -> str:
    """
    Returns the current UTC datetime as a human-readable string.

    Returns:
        A string in the format 'YYYY-MM-DD HH:MM UTC'.
    """
    return datetime.utcnow().strftime('%Y-%m-%d %H:%M UTC')
