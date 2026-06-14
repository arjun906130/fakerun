"""
validators.py â€” Custom Django model/form field validators for the runner app.
"""

import re
from django.core.exceptions import ValidationError
from .constants import USERNAME_MIN_LENGTH, USERNAME_MAX_LENGTH, USERNAME_ALLOWED_PATTERN


def validate_username(value):
    """
    Validates a player username against the game naming rules:
      - Between USERNAME_MIN_LENGTH and USERNAME_MAX_LENGTH characters
      - Only uppercase letters, digits, and underscores
    Raises ValidationError if the value does not comply.
    """
    if not (USERNAME_MIN_LENGTH <= len(value) <= USERNAME_MAX_LENGTH):
        raise ValidationError(
            f"Username must be between {USERNAME_MIN_LENGTH} and {USERNAME_MAX_LENGTH} characters."
        )
    if not re.match(USERNAME_ALLOWED_PATTERN, value):
        raise ValidationError(
            "Username may only contain uppercase letters (A-Z), digits (0-9), and underscores (_)."
        )


def validate_non_negative_score(value):
    """Ensures a score value is not negative."""
    if value < 0:
        raise ValidationError("Score must be a non-negative integer.")
