"""
constants.py â€” Game-wide constant values.
Centralises magic numbers so they are easy to tune without hunting through views or JS.
"""

# --- Scoring ---
BASE_SCORE_PER_SECOND   = 10      # Points awarded each second while running
CLUTCH_BONUS            = 1_000   # Bonus points for a near-miss CLUTCH event
POWERUP_MULTIPLIER_BOOST = 2      # Score multiplier granted by energy-core pickup
SHIELD_DURATION_SECONDS  = 5      # How long a collected shield lasts

# --- Difficulty speed modifiers (initial units/s) ---
DIFFICULTY_SPEEDS = {
    "easy":   12,
    "medium": 18,
    "hard":   26,
}

# --- Leaderboard ---
LEADERBOARD_MAX_ENTRIES = 15      # Maximum rows shown on the global leaderboard

# --- Username rules ---
USERNAME_MIN_LENGTH = 2
USERNAME_MAX_LENGTH = 12
USERNAME_ALLOWED_PATTERN = r"^[A-Z0-9_]+$"

# --- Rating thresholds ---
RATING_THRESHOLDS = {
    "S": 50_000,
    "A": 25_000,
    "B": 10_000,
    "C":  5_000,
    "D":      0,
}
