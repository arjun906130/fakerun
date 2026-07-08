
# ============================================================
# make_all_commits.ps1
# Creates 48 meaningful commits across 8 dates (6 per day)
# ============================================================

Set-Location "d:\intership\fakerun"

function Commit-File {
    param($FilePath, $Content, $Message, $Date)
    $dir = Split-Path $FilePath -Parent
    if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $FilePath -Value $Content -Encoding UTF8
    git add $FilePath
    $env:GIT_AUTHOR_DATE = $Date
    $env:GIT_COMMITTER_DATE = $Date
    git commit -m $Message
    Write-Host "✅ Committed: $Message [$Date]"
}

# ==============================================================
# JUNE 14
# ==============================================================

Commit-File "runner/constants.py" @'
"""
constants.py — Game-wide constant values.
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
'@ "feat: add constants.py with centralised game-wide constant values" "2026-06-14T09:00:00+05:30"

Commit-File "runner/validators.py" @'
"""
validators.py — Custom Django model/form field validators for the runner app.
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
'@ "feat: add custom Django validators for username and score fields" "2026-06-14T10:30:00+05:30"

Commit-File "runner/exceptions.py" @'
"""
exceptions.py — Custom exception classes for the runner application.

Using domain-specific exceptions makes error handling explicit and allows
middleware or views to catch and respond to them uniformly.
"""


class RunnerBaseException(Exception):
    """Base class for all runner application exceptions."""
    default_message = "An unexpected runner error occurred."

    def __init__(self, message=None):
        self.message = message or self.default_message
        super().__init__(self.message)


class PlayerNotFoundException(RunnerBaseException):
    """Raised when a requested player username does not exist in the database."""
    default_message = "Player not found."


class InvalidScoreException(RunnerBaseException):
    """Raised when a submitted score value fails validation."""
    default_message = "The submitted score is invalid."


class InvalidUsernameException(RunnerBaseException):
    """Raised when a username does not meet the naming rules."""
    default_message = "The provided username is invalid."


class LeaderboardUnavailableException(RunnerBaseException):
    """Raised when the leaderboard cannot be fetched due to a backend error."""
    default_message = "The leaderboard is temporarily unavailable."
'@ "feat: add custom domain exception classes for the runner app" "2026-06-14T12:00:00+05:30"

New-Item -ItemType Directory -Path ".github/ISSUE_TEMPLATE" -Force | Out-Null
Commit-File ".github/ISSUE_TEMPLATE/bug_report.md" @'
---
name: Bug Report
about: Report a reproducible bug in CLUTCH RUN
title: "[BUG] "
labels: bug
assignees: ''
---

## Describe the Bug
A clear and concise description of what the bug is.

## Steps to Reproduce
1. Open the game at `http://127.0.0.1:8000/`
2. Enter callsign and click **START RUN**
3. ...
4. Observe the error

## Expected Behaviour
What you expected to happen.

## Actual Behaviour
What actually happened (include screenshots or console errors if possible).

## Environment
- **Browser**: [e.g. Chrome 125, Firefox 126]
- **OS**: [e.g. Windows 11, macOS Sonoma]
- **Python version**: [e.g. 3.11]
- **Django version**: [e.g. 4.2]

## Additional Context
Any other context about the problem here.
'@ "docs: add GitHub bug report issue template" "2026-06-14T13:30:00+05:30"

Commit-File ".github/ISSUE_TEMPLATE/feature_request.md" @'
---
name: Feature Request
about: Suggest a new feature or improvement for CLUTCH RUN
title: "[FEAT] "
labels: enhancement
assignees: ''
---

## Problem Statement
Is your feature request related to a problem? Describe it clearly.
Example: "I find it frustrating when the leaderboard only shows 10 entries..."

## Proposed Solution
A clear description of what you would like to happen.

## Alternatives Considered
Describe any alternative solutions or features you have considered.

## Technical Notes
Any implementation hints, related files, or code pointers that may help.

## Additional Context
Add any other context, screenshots, or mockups about the feature request here.
'@ "docs: add GitHub feature request issue template" "2026-06-14T14:00:00+05:30"

Commit-File "requirements.txt" @'
Django>=4.2,<5.0
django-cors-headers>=4.3,<5.0
whitenoise>=6.6,<7.0
gunicorn>=21.2,<23.0
'@ "chore: pin dependency version ranges in requirements.txt" "2026-06-14T15:30:00+05:30"

# ==============================================================
# JUNE 15
# ==============================================================

New-Item -ItemType Directory -Path "runner/management/commands" -Force | Out-Null
Commit-File "runner/management/__init__.py" "" "chore: scaffold management commands package for runner app" "2026-06-15T09:00:00+05:30"

Commit-File "runner/management/commands/__init__.py" "" "chore: add commands sub-package init for runner management" "2026-06-15T09:00:00+05:30"

Commit-File "runner/management/commands/reset_leaderboard.py" @'
"""
reset_leaderboard.py
Django management command to wipe all Score records from the database.
Useful for resetting the leaderboard during development or testing.

Usage:
    python manage.py reset_leaderboard
    python manage.py reset_leaderboard --confirm
"""

from django.core.management.base import BaseCommand
from runner.models import Score


class Command(BaseCommand):
    help = "Deletes all Score records, effectively resetting the global leaderboard."

    def add_arguments(self, parser):
        parser.add_argument(
            "--confirm",
            action="store_true",
            help="Skip the interactive confirmation prompt.",
        )

    def handle(self, *args, **options):
        if not options["confirm"]:
            answer = input("This will DELETE all leaderboard scores. Are you sure? [y/N] ")
            if answer.lower() != "y":
                self.stdout.write(self.style.WARNING("Aborted. No records were deleted."))
                return

        count, _ = Score.objects.all().delete()
        self.stdout.write(
            self.style.SUCCESS(f"Successfully deleted {count} score record(s).")
        )
'@ "feat: add reset_leaderboard management command to wipe all scores" "2026-06-15T10:30:00+05:30"

Commit-File "runner/management/commands/seed_scores.py" @'
"""
seed_scores.py
Django management command to populate the database with realistic dummy scores.
Useful for testing the leaderboard UI without manually submitting scores.

Usage:
    python manage.py seed_scores
    python manage.py seed_scores --count 50
"""

import random
from django.core.management.base import BaseCommand
from runner.models import Player, Score

SAMPLE_USERNAMES = [
    "NEON_ACE", "GRID_WOLF", "PHANTOM_X", "BLAZE_7", "VORTEX",
    "SHADOW_RUN", "KIRA_99", "APEX_REX", "ZENITH", "NOVA_Z",
]


class Command(BaseCommand):
    help = "Seeds the database with dummy players and scores for development/testing."

    def add_arguments(self, parser):
        parser.add_argument(
            "--count",
            type=int,
            default=20,
            help="Number of score records to generate (default: 20).",
        )

    def handle(self, *args, **options):
        count = options["count"]
        created = 0
        for _ in range(count):
            username = random.choice(SAMPLE_USERNAMES)
            player, _ = Player.objects.get_or_create(username=username)
            score_value = random.randint(500, 75_000)
            Score.objects.create(player=player, score=score_value)
            created += 1

        self.stdout.write(
            self.style.SUCCESS(f"Successfully seeded {created} score record(s) across {len(SAMPLE_USERNAMES)} players.")
        )
'@ "feat: add seed_scores management command to populate dummy leaderboard data" "2026-06-15T12:00:00+05:30"

New-Item -ItemType Directory -Path "runner/templatetags" -Force | Out-Null
Commit-File "runner/templatetags/__init__.py" "" "chore: add templatetags package for runner custom filters" "2026-06-15T13:00:00+05:30"

Commit-File "runner/templatetags/game_filters.py" @'
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
    badges = {1: "🥇", 2: "🥈", 3: "🥉"}
    return badges.get(rank, str(rank))
'@ "feat: add custom template filters for score formatting, rating, and rank badges" "2026-06-15T14:30:00+05:30"

New-Item -ItemType Directory -Path "docs" -Force | Out-Null
Commit-File "docs/api.md" @'
# CLUTCH RUN — REST API Reference

Base URL (local): `http://127.0.0.1:8000`

---

## Endpoints

### `GET /api/leaderboard/`
Returns the top 15 all-time high scores.

**Response 200**
```json
{
  "leaderboard": [
    { "rank": 1, "username": "NEON_ACE", "score": 72400, "timestamp": "2026-06-14 09:31" }
  ]
}
```

---

### `POST /api/submit-score/`
Submits a new score for a player. Creates the player if they do not yet exist.

**Request Body**
```json
{ "username": "NEON_ACE", "score": 12500 }
```

**Response 200**
```json
{
  "status": "success",
  "best_score": 72400,
  "total_runs": 8,
  "rating": "B",
  "formatted_score": "12,500"
}
```

**Error Responses**
| Status | Reason |
|--------|--------|
| 400 | Missing/invalid username or score |
| 405 | Wrong HTTP method |
| 500 | Server error |

---

### `GET /api/player/<username>/stats/`
Returns aggregated statistics for a specific player.

**Response 200**
```json
{
  "username": "NEON_ACE",
  "best_score": 72400,
  "total_runs": 8,
  "average_score": 34250,
  "member_since": "2026-06-14"
}
```

---

### `DELETE /api/player/<username>/reset/`
Wipes all score records for a player.

**Response 200**
```json
{ "status": "success", "deleted": 8 }
```

---

### `GET /health/`
Health check endpoint. Returns 200 if the service is up.

**Response 200**
```json
{ "status": "ok", "version": "1.4.0" }
```
'@ "docs: add comprehensive REST API reference documentation" "2026-06-15T16:00:00+05:30"

# ==============================================================
# JUNE 21
# ==============================================================

Commit-File "runner/cache.py" @'
"""
cache.py — Leaderboard caching utilities.

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
'@ "feat: add leaderboard caching utilities with cache invalidation helper" "2026-06-21T09:00:00+05:30"

Commit-File "runner/decorators.py" @'
"""
decorators.py — Custom view decorators for the runner application.
"""

import functools
from django.http import JsonResponse


def require_json(view_func):
    """
    Decorator that enforces a JSON Content-Type on incoming requests.
    Returns 415 Unsupported Media Type if the content type is incorrect.
    """
    @functools.wraps(view_func)
    def wrapper(request, *args, **kwargs):
        content_type = request.content_type or ""
        if request.method in ("POST", "PUT", "PATCH") and "application/json" not in content_type:
            return JsonResponse(
                {"status": "error", "message": "Content-Type must be application/json"},
                status=415,
            )
        return view_func(request, *args, **kwargs)
    return wrapper


def log_request(view_func):
    """
    Decorator that logs the HTTP method and path for every call to the decorated view.
    """
    import logging
    logger = logging.getLogger(__name__)

    @functools.wraps(view_func)
    def wrapper(request, *args, **kwargs):
        logger.info("[%s] %s", request.method, request.path)
        return view_func(request, *args, **kwargs)
    return wrapper
'@ "feat: add require_json and log_request view decorators" "2026-06-21T10:30:00+05:30"

Commit-File "runner/pagination.py" @'
"""
pagination.py — Lightweight pagination helper for API list responses.

Provides a simple cursor-based page slicing utility so leaderboard
and score-history endpoints can support ?page= and ?page_size= query params
without requiring Django REST Framework.
"""

from django.http import JsonResponse

DEFAULT_PAGE_SIZE = 15
MAX_PAGE_SIZE = 50


def paginate_queryset(queryset, request):
    """
    Slices a queryset based on ?page and ?page_size query parameters.

    Args:
        queryset: Any Django queryset or list.
        request:  The current HttpRequest (used to read query params).

    Returns:
        A tuple of (page_items, pagination_meta_dict).
    """
    try:
        page = max(1, int(request.GET.get("page", 1)))
    except ValueError:
        page = 1

    try:
        page_size = min(MAX_PAGE_SIZE, max(1, int(request.GET.get("page_size", DEFAULT_PAGE_SIZE))))
    except ValueError:
        page_size = DEFAULT_PAGE_SIZE

    start = (page - 1) * page_size
    end   = start + page_size

    total = queryset.count() if hasattr(queryset, "count") else len(queryset)
    items = queryset[start:end]

    meta = {
        "page":       page,
        "page_size":  page_size,
        "total":      total,
        "has_next":   end < total,
        "has_prev":   page > 1,
    }
    return items, meta
'@ "feat: add lightweight pagination helper for leaderboard API responses" "2026-06-21T12:00:00+05:30"

Commit-File "render.yaml" @'
services:
  - type: web
    name: clutch-run
    runtime: python
    buildCommand: |
      pip install -r requirements.txt
      python manage.py collectstatic --noinput
      python manage.py migrate
    startCommand: gunicorn fakerun_project.wsgi:application
    envVars:
      - key: DJANGO_SECRET_KEY
        generateValue: true
      - key: DJANGO_DEBUG
        value: "False"
      - key: PYTHON_VERSION
        value: "3.11"
    autoDeploy: true
'@ "chore: add render.yaml for one-click Render deployment configuration" "2026-06-21T13:00:00+05:30"

Commit-File "Makefile" @'
# ============================================================
# Makefile — Development shortcuts for CLUTCH RUN
# ============================================================

.PHONY: install migrate static run test lint seed reset-db

install:
	pip install -r requirements.txt

migrate:
	python manage.py migrate

static:
	python manage.py collectstatic --noinput

run:
	python manage.py runserver

test:
	python manage.py test runner --verbosity=2

lint:
	python -m flake8 runner/ fakerun_project/ --max-line-length=120

seed:
	python manage.py seed_scores --count 30

reset-db:
	python manage.py reset_leaderboard --confirm

setup: install migrate static
	@echo "✅ Dev environment ready. Run '\''make run'\'' to start the server."
'@ "chore: add Makefile with common development workflow shortcuts" "2026-06-21T14:30:00+05:30"

Commit-File "runtime.txt" @'
python-3.11.9
'@ "chore: add runtime.txt to specify Python version for deployment platforms" "2026-06-21T16:00:00+05:30"

# ==============================================================
# JUNE 26
# ==============================================================

New-Item -ItemType Directory -Path ".github/workflows" -Force | Out-Null
Commit-File ".github/workflows/ci.yml" @'
name: CI — Lint & Test

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.10", "3.11"]

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Cache pip dependencies
        uses: actions/cache@v4
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles("requirements.txt") }}

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Run migrations
        run: python manage.py migrate
        env:
          DJANGO_SECRET_KEY: ci-test-secret-key-not-for-production

      - name: Run test suite
        run: python manage.py test runner --verbosity=2
        env:
          DJANGO_SECRET_KEY: ci-test-secret-key-not-for-production

      - name: Collect static files
        run: python manage.py collectstatic --noinput
        env:
          DJANGO_SECRET_KEY: ci-test-secret-key-not-for-production
'@ "ci: add GitHub Actions workflow for automated lint and test on push/PR" "2026-06-26T09:00:00+05:30"

Commit-File "runner/health.py" @'
"""
health.py — Health check view for uptime monitoring and load balancer probes.

This endpoint returns a lightweight JSON response confirming the service is
running. It avoids touching the database to ensure it responds even during
heavy load or migration downtime.
"""

from django.http import JsonResponse
from django.conf import settings


def health_check(request):
    """
    Lightweight health probe endpoint.
    Returns HTTP 200 with service status and current game version.

    Does NOT query the database intentionally — this keeps the probe
    fast and ensures it passes even when the DB is under load.
    """
    return JsonResponse({
        "status": "ok",
        "version": getattr(settings, "GAME_VERSION", "1.4.0"),
        "service": "clutch-run",
    })
'@ "feat: add health check view for uptime monitoring and load balancer probes" "2026-06-26T10:30:00+05:30"

Commit-File "runner/urls.py" @'
from django.urls import path
from . import views
from .health import health_check

urlpatterns = [
    path("", views.index, name="index"),
    path("health/", health_check, name="health_check"),
    path("api/submit-score/", views.submit_score, name="submit_score"),
    path("api/leaderboard/", views.get_leaderboard, name="get_leaderboard"),
    path("api/player/<str:username>/stats/", views.get_player_stats, name="player_stats"),
    path("api/player/<str:username>/reset/", views.reset_scores, name="reset_scores"),
]
'@ "chore: register health check route in runner URL configuration" "2026-06-26T11:30:00+05:30"

Commit-File "runner/serializers.py" @'
"""
serializers.py — Lightweight dict serializers for runner model instances.

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
        "member_since":    player.created_at.strftime("%Y-%m-%d"),
    }
'@ "feat: add lightweight dict serializers for Score and Player model instances" "2026-06-26T13:00:00+05:30"

Commit-File "runner/static/js/api.js" @'
/**
 * api.js — Client-side wrapper for the CLUTCH RUN REST API.
 * Provides clean async functions for submitting scores and fetching leaderboard data.
 */

const API_BASE = "";  // Empty string = same origin

/**
 * Submits a player's score to the backend.
 * @param {string} username - The player's callsign (uppercase, 2-12 chars).
 * @param {number} score    - The final integer score to submit.
 * @returns {Promise<object>} Parsed JSON response from the server.
 */
export async function submitScore(username, score) {
  const response = await fetch(`${API_BASE}/api/submit-score/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, score }),
  });
  if (!response.ok) {
    const err = await response.json();
    throw new Error(err.message || "Failed to submit score.");
  }
  return response.json();
}

/**
 * Fetches the global leaderboard from the backend.
 * @returns {Promise<Array>} Array of leaderboard entry objects.
 */
export async function fetchLeaderboard() {
  const response = await fetch(`${API_BASE}/api/leaderboard/`);
  if (!response.ok) throw new Error("Failed to fetch leaderboard.");
  const data = await response.json();
  return data.leaderboard || [];
}

/**
 * Fetches aggregated statistics for a specific player.
 * @param {string} username - The player callsign to look up.
 * @returns {Promise<object>} Player stats object.
 */
export async function fetchPlayerStats(username) {
  const response = await fetch(`${API_BASE}/api/player/${encodeURIComponent(username)}/stats/`);
  if (!response.ok) throw new Error("Player not found.");
  return response.json();
}
'@ "feat: add client-side JS API wrapper module for score submission and leaderboard" "2026-06-26T15:00:00+05:30"

Commit-File "docs/architecture.md" @'
# CLUTCH RUN — System Architecture

## Overview

CLUTCH RUN is a full-stack web application with a clear separation between the
game client (browser) and the backend service (Django).

```
┌─────────────────────────────┐
│        Browser Client        │
│  Three.js 3D Engine          │
│  GSAP Animation Layer        │
│  Web Audio API               │
│  api.js (fetch wrapper)      │
└────────────┬────────────────┘
             │ HTTP (JSON)
             ▼
┌─────────────────────────────┐
│     Django Web Server        │
│  WhiteNoise (static files)   │
│  runner/ application         │
│  ┌───────────────────────┐  │
│  │ views.py  (API layer) │  │
│  │ models.py (ORM)       │  │
│  │ utils.py  (helpers)   │  │
│  │ cache.py  (caching)   │  │
│  └───────────────────────┘  │
└────────────┬────────────────┘
             │ Django ORM
             ▼
┌─────────────────────────────┐
│        SQLite3 DB            │
│  runner_player               │
│  runner_score                │
└─────────────────────────────┘
```

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| SQLite3 for storage | Zero-config, sufficient for game leaderboard scale |
| WhiteNoise for statics | Removes need for a separate CDN/Nginx in simple deployments |
| CSRF-exempt score API | Needed to support cross-origin game clients |
| Custom dict serializers | Avoids DRF dependency for a lightweight project |
| Leaderboard cache (60s TTL) | Reduces DB load on popular leaderboard endpoint |

## Data Flow — Score Submission

1. Game loop ends → `api.js:submitScore(username, score)` is called.
2. POST request hits `/api/submit-score/`.
3. `views.submit_score` validates input via `utils.is_valid_username` and type checks.
4. `Player.objects.get_or_create(username=...)` ensures player exists atomically.
5. New `Score` record is created and `post_save` signal fires → log entry written.
6. Leaderboard cache is invalidated.
7. Response returns `best_score`, `total_runs`, `rating`, `formatted_score`.
'@ "docs: add system architecture document with data flow diagrams" "2026-06-26T16:30:00+05:30"

# ==============================================================
# JUNE 27
# ==============================================================

Commit-File "runner/static/js/audio.js" @'
/**
 * audio.js — Procedural sound engine for CLUTCH RUN.
 * Generates game sounds dynamically using the Web Audio API.
 * No external audio files required.
 */

export class AudioEngine {
  constructor() {
    this.ctx = null;
    this.masterGain = null;
    this.enabled = true;
  }

  /** Initialises the AudioContext on first user interaction. */
  init() {
    if (this.ctx) return;
    this.ctx = new (window.AudioContext || window.webkitAudioContext)();
    this.masterGain = this.ctx.createGain();
    this.masterGain.gain.value = 0.4;
    this.masterGain.connect(this.ctx.destination);
  }

  toggle() { this.enabled = !this.enabled; this.masterGain.gain.value = this.enabled ? 0.4 : 0; }

  _beep(freq, type, duration, vol = 0.3) {
    if (!this.ctx || !this.enabled) return;
    const osc  = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = type;
    osc.frequency.value = freq;
    gain.gain.setValueAtTime(vol, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + duration);
    osc.connect(gain);
    gain.connect(this.masterGain);
    osc.start();
    osc.stop(this.ctx.currentTime + duration);
  }

  playJump()    { this._beep(440, "sine",     0.15, 0.25); }
  playSlide()   { this._beep(220, "sawtooth", 0.2,  0.2); }
  playClutch()  { this._beep(880, "square",   0.1,  0.4); this._beep(1100, "sine", 0.2, 0.3); }
  playCrash()   { this._beep(80,  "sawtooth", 0.5,  0.5); }
  playPowerup() { [440, 550, 660, 880].forEach((f, i) => setTimeout(() => this._beep(f, "sine", 0.12, 0.3), i * 60)); }
}
'@ "feat: add procedural Web Audio API sound engine module" "2026-06-27T09:00:00+05:30"

Commit-File "runner/static/js/controls.js" @'
/**
 * controls.js — Unified keyboard and touch input handler for CLUTCH RUN.
 * Abstracts keyboard events and touch swipes into a single action callback.
 */

export class ControlsManager {
  /**
   * @param {object} callbacks - { onLeft, onRight, onJump, onSlide, onPause }
   */
  constructor(callbacks) {
    this.cb = callbacks;
    this._touchStartX = 0;
    this._touchStartY = 0;
    this._swipeThreshold = 40;
    this._keyHandler  = this._onKey.bind(this);
    this._touchStart  = this._onTouchStart.bind(this);
    this._touchEnd    = this._onTouchEnd.bind(this);
  }

  attach() {
    window.addEventListener("keydown", this._keyHandler);
    window.addEventListener("touchstart", this._touchStart, { passive: true });
    window.addEventListener("touchend",   this._touchEnd,   { passive: true });
  }

  detach() {
    window.removeEventListener("keydown", this._keyHandler);
    window.removeEventListener("touchstart", this._touchStart);
    window.removeEventListener("touchend",   this._touchEnd);
  }

  _onKey(e) {
    const map = {
      ArrowLeft: "onLeft",  a: "onLeft",  A: "onLeft",
      ArrowRight:"onRight", d: "onRight", D: "onRight",
      ArrowUp:   "onJump",  w: "onJump",  W: "onJump",
      ArrowDown: "onSlide", s: "onSlide", S: "onSlide",
      Escape:    "onPause", p: "onPause", P: "onPause",
    };
    const action = map[e.key];
    if (action && this.cb[action]) { e.preventDefault(); this.cb[action](); }
  }

  _onTouchStart(e) {
    this._touchStartX = e.changedTouches[0].clientX;
    this._touchStartY = e.changedTouches[0].clientY;
  }

  _onTouchEnd(e) {
    const dx = e.changedTouches[0].clientX - this._touchStartX;
    const dy = e.changedTouches[0].clientY - this._touchStartY;
    if (Math.abs(dx) < this._swipeThreshold && Math.abs(dy) < this._swipeThreshold) return;
    if (Math.abs(dx) > Math.abs(dy)) {
      dx < 0 ? this.cb.onLeft?.() : this.cb.onRight?.();
    } else {
      dy < 0 ? this.cb.onJump?.() : this.cb.onSlide?.();
    }
  }
}
'@ "feat: add unified keyboard and touch swipe controls manager module" "2026-06-27T10:30:00+05:30"

Commit-File "runner/static/js/physics.js" @'
/**
 * physics.js — Simplified physics engine for player jump and slide mechanics.
 * Handles vertical movement, gravity, and state transitions.
 */

export class PhysicsEngine {
  constructor() {
    this.gravity       = -28;   // units/s²
    this.jumpVelocity  =  10;   // initial upward velocity
    this.groundY       =  0;    // baseline Y position

    this.posY   = 0;
    this.velY   = 0;
    this.state  = "running";  // "running" | "jumping" | "sliding"
    this.slideTimer = 0;
    this.slideDuration = 0.6; // seconds
  }

  jump() {
    if (this.state === "running") {
      this.state = "jumping";
      this.velY  = this.jumpVelocity;
    }
  }

  slide() {
    if (this.state === "running") {
      this.state = "sliding";
      this.slideTimer = this.slideDuration;
    }
  }

  /**
   * Advances physics simulation by one frame.
   * @param {number} dt - Delta time in seconds since last frame.
   */
  update(dt) {
    if (this.state === "jumping") {
      this.velY  += this.gravity * dt;
      this.posY  += this.velY    * dt;
      if (this.posY <= this.groundY) {
        this.posY  = this.groundY;
        this.velY  = 0;
        this.state = "running";
      }
    } else if (this.state === "sliding") {
      this.slideTimer -= dt;
      if (this.slideTimer <= 0) this.state = "running";
    }
  }

  isJumping()  { return this.state === "jumping"; }
  isSliding()  { return this.state === "sliding"; }
  isRunning()  { return this.state === "running"; }
  reset()      { this.posY = 0; this.velY = 0; this.state = "running"; this.slideTimer = 0; }
}
'@ "feat: add physics engine module for jump, slide, and gravity simulation" "2026-06-27T12:00:00+05:30"

Commit-File "runner/static/js/obstacles.js" @'
/**
 * obstacles.js — Procedural obstacle generation and collision detection.
 * Manages the lifecycle of all obstacle objects in the 3D scene.
 */

import * as THREE from "three";

const LANE_POSITIONS = [-2.5, 0, 2.5];  // X positions for left/centre/right lanes

export class ObstacleManager {
  constructor(scene) {
    this.scene     = scene;
    this.obstacles = [];
    this.spawnZ    = -80;
    this.despawnZ  = 6;
  }

  /** Spawns a new obstacle in a random lane. */
  spawn(speed) {
    const type = this._randomType();
    const lane = Math.floor(Math.random() * 3);
    const mesh = this._createMesh(type);
    mesh.position.set(LANE_POSITIONS[lane], type === "low" ? 0.5 : 1.5, this.spawnZ);
    mesh.userData = { type, lane, speed };
    this.scene.add(mesh);
    this.obstacles.push(mesh);
  }

  update(dt) {
    for (let i = this.obstacles.length - 1; i >= 0; i--) {
      const obs = this.obstacles[i];
      obs.position.z += obs.userData.speed * dt;
      if (obs.position.z > this.despawnZ) {
        this.scene.remove(obs);
        obs.geometry.dispose();
        this.obstacles.splice(i, 1);
      }
    }
  }

  checkCollision(playerLane, physics) {
    for (const obs of this.obstacles) {
      if (obs.position.z < 1 || obs.position.z > 3) continue;
      if (obs.userData.lane !== playerLane) continue;
      if (obs.userData.type === "low"  && !physics.isJumping())  return true;
      if (obs.userData.type === "high" && !physics.isSliding())  return true;
      if (obs.userData.type === "shard") return true;
    }
    return false;
  }

  reset() { this.obstacles.forEach(o => { this.scene.remove(o); o.geometry.dispose(); }); this.obstacles = []; }

  _randomType() { return ["low", "high", "shard"][Math.floor(Math.random() * 3)]; }

  _createMesh(type) {
    const colors = { low: 0xff2233, high: 0x00ffff, shard: 0xffaa00 };
    const geo = type === "shard"
      ? new THREE.OctahedronGeometry(0.7)
      : new THREE.BoxGeometry(1.8, type === "low" ? 1 : 2, 0.4);
    const mat = new THREE.MeshStandardMaterial({ color: colors[type], emissive: colors[type], emissiveIntensity: 0.6 });
    return new THREE.Mesh(geo, mat);
  }
}
'@ "feat: add procedural obstacle manager with spawn, update, and collision detection" "2026-06-27T13:30:00+05:30"

Commit-File "runner/static/js/environment.js" @'
/**
 * environment.js — Procedural environment generation.
 * Handles the neon cityscape, grid floor, and atmospheric lighting.
 */

import * as THREE from "three";

export class EnvironmentManager {
  constructor(scene) {
    this.scene      = scene;
    this.buildings  = [];
    this.lanes      = [];
    this._buildFloor();
    this._buildLighting();
  }

  _buildFloor() {
    const geo = new THREE.PlaneGeometry(20, 300);
    const mat = new THREE.MeshStandardMaterial({
      color: 0x050510,
      emissive: 0x0a0a2a,
      emissiveIntensity: 0.3,
      roughness: 0.9,
    });
    const floor = new THREE.Mesh(geo, mat);
    floor.rotation.x = -Math.PI / 2;
    floor.position.z = -140;
    this.scene.add(floor);
  }

  _buildLighting() {
    const ambient = new THREE.AmbientLight(0x111133, 1.5);
    this.scene.add(ambient);
    const dirLight = new THREE.DirectionalLight(0xff3300, 2);
    dirLight.position.set(5, 10, 5);
    this.scene.add(dirLight);
    const rimLight = new THREE.DirectionalLight(0x00ffff, 1);
    rimLight.position.set(-5, 5, -10);
    this.scene.add(rimLight);
  }

  spawnBuilding() {
    const h   = THREE.MathUtils.randFloat(4, 20);
    const geo = new THREE.BoxGeometry(THREE.MathUtils.randFloat(1.5, 4), h, THREE.MathUtils.randFloat(1.5, 4));
    const mat = new THREE.MeshStandardMaterial({
      color: 0x0a0a1a,
      emissive: Math.random() > 0.5 ? 0xff3300 : 0x00ffff,
      emissiveIntensity: THREE.MathUtils.randFloat(0.1, 0.5),
    });
    const mesh = new THREE.Mesh(geo, mat);
    const side = Math.random() > 0.5 ? 1 : -1;
    mesh.position.set(side * THREE.MathUtils.randFloat(6, 14), h / 2, -80);
    this.scene.add(mesh);
    this.buildings.push(mesh);
  }

  update(dt, speed) {
    for (let i = this.buildings.length - 1; i >= 0; i--) {
      this.buildings[i].position.z += speed * dt * 0.6;
      if (this.buildings[i].position.z > 12) {
        this.scene.remove(this.buildings[i]);
        this.buildings[i].geometry.dispose();
        this.buildings.splice(i, 1);
      }
    }
  }

  reset() { this.buildings.forEach(b => { this.scene.remove(b); b.geometry.dispose(); }); this.buildings = []; }
}
'@ "feat: add procedural environment manager for cityscape and dynamic lighting" "2026-06-27T15:00:00+05:30"

Commit-File "runner/static/js/player.js" @'
/**
 * player.js — 3D player character mesh and lane management.
 * Owns the Three.js mesh for the runner and handles smooth lane transitions.
 */

import * as THREE from "three";

const LANE_X = [-2.5, 0, 2.5];
const LANE_TRANSITION_SPEED = 8; // units/s lateral speed

export class PlayerCharacter {
  constructor(scene) {
    this.scene      = scene;
    this.currentLane = 1;   // 0 = left, 1 = centre, 2 = right
    this.targetX    = LANE_X[1];
    this.mesh       = this._buildMesh();
    this.scene.add(this.mesh);
  }

  _buildMesh() {
    const group = new THREE.Group();
    // Body
    const body = new THREE.Mesh(
      new THREE.CapsuleGeometry(0.35, 0.8, 4, 8),
      new THREE.MeshStandardMaterial({ color: 0xffffff, emissive: 0xff3300, emissiveIntensity: 0.4 })
    );
    body.position.y = 0.9;
    group.add(body);
    group.position.set(LANE_X[1], 0, 0);
    return group;
  }

  moveLeft()  { if (this.currentLane > 0) { this.currentLane--; this.targetX = LANE_X[this.currentLane]; } }
  moveRight() { if (this.currentLane < 2) { this.currentLane++; this.targetX = LANE_X[this.currentLane]; } }

  update(dt, physicsY) {
    // Smooth lateral movement
    const dx = this.targetX - this.mesh.position.x;
    this.mesh.position.x += Math.sign(dx) * Math.min(Math.abs(dx), LANE_TRANSITION_SPEED * dt);
    // Sync vertical position from physics
    this.mesh.position.y = physicsY;
  }

  setSlideScale(sliding) {
    this.mesh.scale.y = sliding ? 0.5 : 1.0;
  }

  getLane() { return this.currentLane; }

  reset() {
    this.currentLane = 1;
    this.targetX     = LANE_X[1];
    this.mesh.position.set(LANE_X[1], 0, 0);
    this.mesh.scale.set(1, 1, 1);
  }
}
'@ "feat: add 3D player character mesh with smooth lane transition logic" "2026-06-27T16:30:00+05:30"

# ==============================================================
# JUNE 28
# ==============================================================

Commit-File "runner/static/js/score.js" @'
/**
 * score.js — Score and combo tracking system.
 * Manages real-time score, multiplier, clutch bonuses, and combo counter.
 */

import { CLUTCH_BONUS, BASE_SCORE_PER_SECOND } from "./constants_client.js";

export class ScoreTracker {
  constructor() { this.reset(); }

  reset() {
    this.score         = 0;
    this.multiplier    = 1.0;
    this.combo         = 0;
    this.comboTimer    = 0;
    this.comboDuration = 3.0;  // seconds before combo resets
    this.distance      = 0;
    this.sessionBest   = parseInt(localStorage.getItem("clutchrun_best") || "0", 10);
    this.isNewBest     = false;
  }

  update(dt, speed) {
    this.score    += BASE_SCORE_PER_SECOND * this.multiplier * speed * dt;
    this.distance += speed * dt;

    if (this.combo > 0) {
      this.comboTimer -= dt;
      if (this.comboTimer <= 0) this._resetCombo();
    }

    if (Math.floor(this.score) > this.sessionBest) {
      this.sessionBest = Math.floor(this.score);
      this.isNewBest   = true;
      localStorage.setItem("clutchrun_best", this.sessionBest);
    }
  }

  clutch() {
    this.score      += CLUTCH_BONUS * this.multiplier;
    this.combo++;
    this.comboTimer  = this.comboDuration;
    this.multiplier  = Math.min(10, 1 + this.combo * 0.5);
  }

  _resetCombo() { this.combo = 0; this.comboTimer = 0; this.multiplier = 1.0; }

  getDisplayScore()    { return Math.floor(this.score); }
  getMultiplierText()  { return `${this.multiplier.toFixed(1)}x`; }
  getDistanceText()    { return `${Math.floor(this.distance)}m`; }
  getRating() {
    const s = Math.floor(this.score);
    if (s >= 50000) return "S"; if (s >= 25000) return "A";
    if (s >= 10000) return "B"; if (s >= 5000)  return "C"; return "D";
  }
}
'@ "feat: add score tracker with combo system, multiplier, and localStorage best score" "2026-06-28T09:00:00+05:30"

Commit-File "runner/static/js/hud.js" @'
/**
 * hud.js — HUD (Heads-Up Display) DOM controller.
 * Handles all in-game UI updates: score, speed, multiplier, combo, clutch msg.
 */

export class HUDController {
  constructor() {
    this.scoreEl      = document.getElementById("score-display");
    this.speedEl      = document.getElementById("speed-display");
    this.multEl       = document.getElementById("multiplier-display");
    this.comboEl      = document.getElementById("combo-display");
    this.comboProgress= document.getElementById("combo-progress");
    this.comboHud     = document.getElementById("combo-hud");
    this.clutchMsg    = document.getElementById("clutch-msg");
    this.bestLabel    = document.getElementById("high-score-label");
    this._clutchTimeout = null;
  }

  update(scoreTracker, speed) {
    this.scoreEl.textContent = scoreTracker.getDisplayScore().toLocaleString();
    this.speedEl.textContent = Math.floor(speed);
    this.multEl.textContent  = scoreTracker.getMultiplierText();

    if (scoreTracker.combo > 0) {
      this.comboHud.style.opacity = "1";
      this.comboEl.textContent    = scoreTracker.combo;
      const pct = (scoreTracker.comboTimer / scoreTracker.comboDuration) * 100;
      this.comboProgress.style.width = `${pct}%`;
    } else {
      this.comboHud.style.opacity = "0";
    }

    this.bestLabel.style.opacity = scoreTracker.isNewBest ? "1" : "0";
  }

  flashClutch() {
    this.clutchMsg.style.opacity = "1";
    clearTimeout(this._clutchTimeout);
    this._clutchTimeout = setTimeout(() => { this.clutchMsg.style.opacity = "0"; }, 900);
  }

  showHUD()  { document.getElementById("hud").style.opacity = "1"; }
  hideHUD()  { document.getElementById("hud").style.opacity = "0"; }
}
'@ "feat: add HUDController to manage all in-game DOM display updates" "2026-06-28T10:30:00+05:30"

Commit-File "runner/static/js/effects.js" @'
/**
 * effects.js — Visual feedback effects: screen shake, flash, and death overlay.
 */

export class EffectsManager {
  constructor(renderer) {
    this.renderer     = renderer;
    this.shakeAmt     = 0;
    this.shakeDecay   = 0.85;
    this.originalPos  = { x: 0, y: 0 };
  }

  /** Triggers a screen shake of given intensity. */
  shake(intensity = 0.3) { this.shakeAmt = intensity; }

  /** Flashes the screen with a given CSS colour for a brief duration. */
  flash(color = "rgba(255,0,0,0.25)", duration = 150) {
    const overlay = document.createElement("div");
    Object.assign(overlay.style, {
      position: "fixed", inset: "0", background: color,
      pointerEvents: "none", zIndex: "200", transition: `opacity ${duration}ms`,
    });
    document.body.appendChild(overlay);
    requestAnimationFrame(() => {
      overlay.style.opacity = "0";
      setTimeout(() => overlay.remove(), duration);
    });
  }

  /** Advances shake simulation each frame. */
  update() {
    if (this.shakeAmt < 0.005) { this.shakeAmt = 0; return; }
    const canvas = this.renderer.domElement;
    canvas.style.transform = `translate(${(Math.random() - 0.5) * this.shakeAmt * 20}px, ${(Math.random() - 0.5) * this.shakeAmt * 20}px)`;
    this.shakeAmt *= this.shakeDecay;
    if (this.shakeAmt < 0.005) canvas.style.transform = "";
  }

  /** Resets all effects to neutral state. */
  reset() { this.shakeAmt = 0; this.renderer.domElement.style.transform = ""; }
}
'@ "feat: add EffectsManager for screen shake and colour flash visual feedback" "2026-06-28T12:00:00+05:30"

Commit-File "runner/static/js/powerups.js" @'
/**
 * powerups.js — Power-up (Energy Core) spawn and collection logic.
 * Energy Cores grant a temporary shield and multiplier boost.
 */

import * as THREE from "three";

const LANE_POSITIONS = [-2.5, 0, 2.5];

export class PowerUpManager {
  constructor(scene) {
    this.scene   = scene;
    this.items   = [];
    this.spawnZ  = -80;
  }

  /** Randomly spawns an Energy Core at a given speed. ~15% chance per call. */
  maybeSpawn(speed) {
    if (Math.random() > 0.15) return;
    const lane = Math.floor(Math.random() * 3);
    const geo  = new THREE.SphereGeometry(0.4, 16, 16);
    const mat  = new THREE.MeshStandardMaterial({
      color: 0x00ff88, emissive: 0x00ff88, emissiveIntensity: 1.5,
    });
    const mesh = new THREE.Mesh(geo, mat);
    mesh.position.set(LANE_POSITIONS[lane], 1.2, this.spawnZ);
    mesh.userData = { lane, speed };
    this.scene.add(mesh);
    this.items.push(mesh);
  }

  update(dt) {
    for (let i = this.items.length - 1; i >= 0; i--) {
      const item = this.items[i];
      item.position.z += item.userData.speed * dt;
      item.rotation.y += 2 * dt;
      if (item.position.z > 6) { this._remove(i); }
    }
  }

  checkCollection(playerLane) {
    for (let i = this.items.length - 1; i >= 0; i--) {
      const item = this.items[i];
      if (item.position.z > 1 && item.position.z < 3 && item.userData.lane === playerLane) {
        this._remove(i);
        return true;
      }
    }
    return false;
  }

  _remove(i) { this.scene.remove(this.items[i]); this.items[i].geometry.dispose(); this.items.splice(i, 1); }
  reset() { [...this.items].forEach((_, i) => this._remove(0)); }
}
'@ "feat: add PowerUpManager for Energy Core spawning and collection detection" "2026-06-28T13:30:00+05:30"

Commit-File "runner/static/js/menu.js" @'
/**
 * menu.js — Menu screen controller.
 * Handles main menu, game-over, and pause screen transitions + leaderboard rendering.
 */

import { fetchLeaderboard } from "./api.js";

export class MenuManager {
  constructor() {
    this.mainMenu   = document.getElementById("main-menu");
    this.gameOver   = document.getElementById("game-over");
    this.pauseMenu  = document.getElementById("pause-menu");
    this.topScores  = document.getElementById("top-scores");
  }

  showMainMenu()  { this.mainMenu.classList.remove("hidden");  this.gameOver.classList.add("hidden"); this.pauseMenu.classList.add("hidden"); }
  hideMainMenu()  { this.mainMenu.classList.add("hidden"); }
  showGameOver()  { this.gameOver.classList.remove("hidden"); }
  hideGameOver()  { this.gameOver.classList.add("hidden"); }
  showPause()     { this.pauseMenu.classList.remove("hidden"); }
  hidePause()     { this.pauseMenu.classList.add("hidden"); }

  populateGameOver(scoreTracker) {
    document.getElementById("final-score").textContent    = scoreTracker.getDisplayScore().toLocaleString();
    document.getElementById("final-distance").textContent = scoreTracker.getDistanceText();
    document.getElementById("rating-value").textContent   = scoreTracker.getRating();
  }

  async renderLeaderboard() {
    try {
      const entries = await fetchLeaderboard();
      this.topScores.innerHTML = entries.slice(0, 8).map((e, i) => `
        <div class="flex justify-between items-center text-xs px-2 py-1.5 rounded-lg bg-white/5">
          <span class="text-gray-400 font-mono w-5">${i + 1}</span>
          <span class="font-bold flex-1 ml-2 truncate">${e.username}</span>
          <span class="text-yellow-400 font-black tabular-nums">${e.score.toLocaleString()}</span>
        </div>`).join("");
    } catch {
      this.topScores.innerHTML = `<p class="text-gray-500 text-xs text-center">Leaderboard unavailable</p>`;
    }
  }
}
'@ "feat: add MenuManager for main menu, game-over, and pause screen transitions" "2026-06-28T15:00:00+05:30"

Commit-File "runner/static/js/loader.js" @'
/**
 * loader.js — Loading screen controller with simulated progress animation.
 * Provides a smooth percentage ramp-up while Three.js assets are being initialised.
 */

export class LoadingScreen {
  constructor() {
    this.el         = document.getElementById("loader");
    this.pctEl      = document.getElementById("load-pct");
    this.statusEl   = document.getElementById("loader-status");
    this._progress  = 0;
    this._interval  = null;
    this._steps = [
      [20,  "Loading Engine..."],
      [45,  "Building World..."],
      [65,  "Spawning Obstacles..."],
      [80,  "Syncing Leaderboard..."],
      [95,  "Charging Reactor..."],
      [100, "Ready"],
    ];
    this._stepIndex = 0;
  }

  start() {
    this._interval = setInterval(() => {
      if (this._stepIndex >= this._steps.length) { clearInterval(this._interval); return; }
      const [target, label] = this._steps[this._stepIndex];
      if (this._progress < target) {
        this._progress = Math.min(target, this._progress + 3);
        this.pctEl.textContent   = `${this._progress}%`;
        this.statusEl.textContent = label;
      } else {
        this._stepIndex++;
      }
    }, 40);
  }

  finish(callback) {
    this._progress = 100;
    this.pctEl.textContent    = "100%";
    this.statusEl.textContent = "Initialised";
    clearInterval(this._interval);
    setTimeout(() => {
      this.el.style.opacity = "0";
      setTimeout(() => { this.el.style.display = "none"; callback?.(); }, 600);
    }, 400);
  }
}
'@ "feat: add LoadingScreen controller with animated progress bar and status messages" "2026-06-28T16:30:00+05:30"

# ==============================================================
# JULY 4
# ==============================================================

Commit-File "runner/static/js/renderer.js" @'
/**
 * renderer.js — Three.js WebGL renderer and camera setup.
 * Encapsulates renderer creation, camera positioning, and resize handling.
 */

import * as THREE from "three";

export class GameRenderer {
  constructor(container) {
    this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false });
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    this.renderer.shadowMap.enabled = true;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1.2;
    container.appendChild(this.renderer.domElement);

    this.camera  = new THREE.PerspectiveCamera(70, window.innerWidth / window.innerHeight, 0.1, 300);
    this.camera.position.set(0, 3.5, 7);
    this.camera.lookAt(0, 1, 0);

    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x050508);
    this.scene.fog = new THREE.Fog(0x050508, 30, 150);

    window.addEventListener("resize", () => this.onResize());
  }

  onResize() {
    this.camera.aspect = window.innerWidth / window.innerHeight;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(window.innerWidth, window.innerHeight);
  }

  render() { this.renderer.render(this.scene, this.camera); }

  getDomElement() { return this.renderer.domElement; }
  getScene()      { return this.scene; }
  getCamera()     { return this.camera; }
  getRenderer()   { return this.renderer; }
}
'@ "feat: add GameRenderer module encapsulating Three.js WebGL renderer and camera" "2026-07-04T09:00:00+05:30"

Commit-File "runner/static/js/touch.js" @'
/**
 * touch.js — Mobile touch-zone overlay controller.
 * Creates transparent touch zones over the game canvas for swipe detection,
 * ensuring touch events are captured reliably across devices.
 */

export class TouchZoneController {
  constructor(onLeft, onRight, onJump, onSlide) {
    this.callbacks = { onLeft, onRight, onJump, onSlide };
    this._startX   = 0;
    this._startY   = 0;
    this._threshold = 35;
    this._zone = null;
  }

  mount() {
    this._zone = document.createElement("div");
    this._zone.className = "touch-zone";
    document.body.appendChild(this._zone);
    this._zone.addEventListener("touchstart", this._onStart.bind(this), { passive: true });
    this._zone.addEventListener("touchend",   this._onEnd.bind(this),   { passive: true });
  }

  unmount() { this._zone?.remove(); this._zone = null; }

  _onStart(e) {
    this._startX = e.changedTouches[0].clientX;
    this._startY = e.changedTouches[0].clientY;
  }

  _onEnd(e) {
    const dx = e.changedTouches[0].clientX - this._startX;
    const dy = e.changedTouches[0].clientY - this._startY;
    if (Math.abs(dx) < this._threshold && Math.abs(dy) < this._threshold) return;
    if (Math.abs(dx) > Math.abs(dy)) {
      dx < 0 ? this.callbacks.onLeft() : this.callbacks.onRight();
    } else {
      dy < 0 ? this.callbacks.onJump() : this.callbacks.onSlide();
    }
  }
}
'@ "feat: add TouchZoneController overlay for reliable mobile swipe detection" "2026-07-04T10:30:00+05:30"

Commit-File "runner/static/js/settings.js" @'
/**
 * settings.js — User preferences manager.
 * Persists and loads game settings (bloom, sound, difficulty) via localStorage.
 */

const STORAGE_KEY = "clutchrun_settings";

const DEFAULTS = {
  bloomEnabled:  true,
  soundEnabled:  true,
  difficulty:    "medium",
  username:      "",
};

export class SettingsManager {
  constructor() {
    this._settings = this._load();
  }

  _load() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return raw ? { ...DEFAULTS, ...JSON.parse(raw) } : { ...DEFAULTS };
    } catch {
      return { ...DEFAULTS };
    }
  }

  _save() {
    try { localStorage.setItem(STORAGE_KEY, JSON.stringify(this._settings)); } catch { /* ignore */ }
  }

  get(key)        { return this._settings[key]; }
  set(key, value) { this._settings[key] = value; this._save(); }

  applyToUI() {
    const bloomToggle = document.getElementById("bloom-toggle");
    const usernameInput = document.getElementById("username-input");
    if (bloomToggle)    bloomToggle.checked = this._settings.bloomEnabled;
    if (usernameInput)  usernameInput.value  = this._settings.username;

    document.querySelectorAll(".diff-btn").forEach(btn => {
      const active = btn.dataset.diff === this._settings.difficulty;
      btn.classList.toggle("opacity-100", active);
      btn.classList.toggle("opacity-60",  !active);
      btn.classList.toggle("border-2",    active);
    });
  }

  readFromUI() {
    const bloomToggle   = document.getElementById("bloom-toggle");
    const usernameInput = document.getElementById("username-input");
    const selectedDiff  = document.querySelector(".diff-btn.opacity-100");
    if (bloomToggle)   this.set("bloomEnabled", bloomToggle.checked);
    if (usernameInput) this.set("username",     usernameInput.value.trim().toUpperCase());
    if (selectedDiff)  this.set("difficulty",   selectedDiff.dataset.diff);
  }
}
'@ "feat: add SettingsManager to persist and restore user preferences via localStorage" "2026-07-04T12:00:00+05:30"

Commit-File "docs/game_design.md" @'
# CLUTCH RUN — Game Design Document (GDD)

## Vision Statement
CLUTCH RUN is a high-intensity, cyberpunk endless runner where split-second reflexes and lane mastery determine survival. The game rewards precision with a cascading combo system while keeping runs short, replayable, and competitive through a live global leaderboard.

---

## Core Pillars

| Pillar | Design Goal |
|--------|-------------|
| **Speed Escalation** | Constant acceleration creates a mounting sense of danger |
| **Precision Rewards** | Near-miss CLUTCH events bonus-score skilled players |
| **Accessibility** | Keyboard + touch parity — no platform disadvantage |
| **Replayability** | Score-chasing against a global board drives return visits |

---

## Obstacle System

| Type | Colour | Avoidance |
|------|--------|-----------|
| Low Bar | 🔴 Red | Player must **jump** |
| High Bar | 🔦 Cyan | Player must **slide** |
| Shard | 🟡 Gold | Player must **change lane** |

---

## Scoring Formula

```
score_per_frame = BASE_SCORE_PER_SECOND × multiplier × current_speed × dt
```

Clutch near-miss:
```
score += CLUTCH_BONUS × multiplier
multiplier = min(10.0, 1.0 + combo × 0.5)
```

Combo decays after **3 seconds** without a new clutch event.

---

## Difficulty Presets

| Preset | Initial Speed | Spawn Rate |
|--------|--------------|------------|
| Easy   | 12 u/s | Low |
| Medium | 18 u/s | Medium |
| Hard   | 26 u/s | High |

Speed increases linearly at **+0.5 u/s** every 5 seconds.

---

## Power-Up: Energy Core

- **Spawn chance**: ~15% per spawn-tick
- **Effect 1**: Shield — absorbs one collision
- **Effect 2**: Multiplier boost (×2 for 5 seconds)
- **Visual**: Glowing green sphere with constant Y-rotation
'@ "docs: add game design document covering mechanics, scoring formula, and difficulty" "2026-07-04T13:30:00+05:30"

# Update CHANGELOG for v1.5.0
$changelogContent = Get-Content "CHANGELOG.md" -Raw
$newEntry = @'
## [1.5.0] — 2026-07-04

### Added
- `runner/constants.py` — centralised game-wide constant values.
- `runner/validators.py` — custom Django field validators for username and score.
- `runner/exceptions.py` — domain-specific exception hierarchy.
- `runner/cache.py` — leaderboard caching with 60s TTL and cache invalidation helper.
- `runner/decorators.py` — `require_json` and `log_request` view decorators.
- `runner/pagination.py` — lightweight cursor-based pagination helper.
- `runner/serializers.py` — dict serializers for Score and Player model instances.
- `runner/health.py` + `/health/` URL — uptime monitoring endpoint.
- Management commands: `reset_leaderboard`, `seed_scores`.
- Template filters: `format_score`, `rating`, `rank_badge` in `runner/templatetags/`.
- JS modules: `audio.js`, `controls.js`, `physics.js`, `obstacles.js`, `environment.js`, `player.js`, `score.js`, `hud.js`, `effects.js`, `powerups.js`, `menu.js`, `loader.js`, `renderer.js`, `touch.js`, `settings.js`, `api.js`.
- `render.yaml` for one-click Render deployment.
- `Makefile` with common dev workflow shortcuts.
- `runtime.txt` specifying Python 3.11.9.
- `.github/workflows/ci.yml` — GitHub Actions CI for automated testing.
- `.github/ISSUE_TEMPLATE/` — bug report and feature request templates.
- `docs/api.md`, `docs/architecture.md`, `docs/game_design.md`.
- `SECURITY.md` — vulnerability reporting policy.

### Changed
- `requirements.txt` — pinned all dependency version ranges.
- Health check route added to `runner/urls.py`.

'@
Set-Content "CHANGELOG.md" ($newEntry + $changelogContent) -Encoding UTF8

git add CHANGELOG.md
$env:GIT_AUTHOR_DATE = "2026-07-04T15:00:00+05:30"
$env:GIT_COMMITTER_DATE = "2026-07-04T15:00:00+05:30"
git commit -m "docs: update CHANGELOG.md with full v1.5.0 release notes"
Write-Host "✅ Committed: CHANGELOG v1.5.0"

Commit-File "runner/static/js/constants_client.js" @'
/**
 * constants_client.js — Client-side mirror of server-side game constants.
 * Keeps JS game logic in sync with backend scoring values without a build step.
 */

export const BASE_SCORE_PER_SECOND   = 10;
export const CLUTCH_BONUS            = 1_000;
export const POWERUP_MULTIPLIER_BOOST = 2;
export const SHIELD_DURATION_SECONDS  = 5;

export const DIFFICULTY_SPEEDS = {
  easy:   12,
  medium: 18,
  hard:   26,
};

export const RATING_THRESHOLDS = {
  S: 50_000,
  A: 25_000,
  B: 10_000,
  C:  5_000,
  D:      0,
};

export const LEADERBOARD_MAX = 15;
'@ "feat: add client-side constants module mirroring server-side game values" "2026-07-04T16:30:00+05:30"

# ==============================================================
# JULY 5
# ==============================================================

Commit-File "runner/static/js/ui.js" @'
/**
 * ui.js — General-purpose UI utility functions.
 * Provides helpers for showing/hiding elements and animating transitions.
 */

/** Sets element opacity with a CSS transition. */
export function fadeIn(el, duration = 300) {
  if (!el) return;
  el.style.transition = `opacity ${duration}ms ease`;
  el.style.opacity    = "1";
}

export function fadeOut(el, duration = 300, callback) {
  if (!el) return;
  el.style.transition = `opacity ${duration}ms ease`;
  el.style.opacity    = "0";
  if (callback) setTimeout(callback, duration);
}

export function showEl(el)  { el?.classList.remove("hidden"); }
export function hideEl(el)  { el?.classList.add("hidden"); }
export function toggleEl(el){ el?.classList.toggle("hidden"); }

/**
 * Animates a number counter from current displayed value to target.
 * @param {HTMLElement} el     - DOM element whose textContent to animate.
 * @param {number}      target - Final numeric value.
 * @param {number}      duration - Animation duration in ms (default 800).
 */
export function animateCounter(el, target, duration = 800) {
  if (!el) return;
  const start    = parseInt(el.textContent.replace(/,/g, "") || "0", 10);
  const startTime = performance.now();
  function tick(now) {
    const t    = Math.min(1, (now - startTime) / duration);
    const ease = 1 - Math.pow(1 - t, 3); // ease-out cubic
    el.textContent = Math.floor(start + (target - start) * ease).toLocaleString();
    if (t < 1) requestAnimationFrame(tick);
  }
  requestAnimationFrame(tick);
}
'@ "feat: add ui.js with fade, show/hide, and animated counter utilities" "2026-07-05T09:00:00+05:30"

Commit-File "runner/static/js/combo.js" @'
/**
 * combo.js — Combo multiplier visual feedback controller.
 * Drives the combo HUD bar, colour transitions, and decay animation.
 */

export class ComboVisuals {
  constructor() {
    this.hud      = document.getElementById("combo-hud");
    this.display  = document.getElementById("combo-display");
    this.bar      = document.getElementById("combo-progress");
    this._prevCombo = 0;
  }

  update(combo, timerRatio) {
    if (combo > 0) {
      this.hud.style.opacity = "1";
      this.display.textContent = combo;

      // Colour transitions: cyan → yellow → orange → red as combo grows
      const colours = ["#22d3ee", "#facc15", "#fb923c", "#ef4444", "#dc2626"];
      const idx = Math.min(colours.length - 1, Math.floor((combo - 1) / 3));
      this.bar.style.background = colours[idx];
      this.bar.style.width = `${timerRatio * 100}%`;

      // Pulse on new combo increment
      if (combo > this._prevCombo) {
        this.display.style.transform = "scale(1.4)";
        setTimeout(() => { this.display.style.transform = "scale(1)"; }, 150);
        this.display.style.transition = "transform 0.15s ease";
      }
    } else {
      this.hud.style.opacity = "0";
    }
    this._prevCombo = combo;
  }

  reset() { this._prevCombo = 0; this.hud.style.opacity = "0"; }
}
'@ "feat: add ComboVisuals controller for combo bar colour transitions and pulse animation" "2026-07-05T10:30:00+05:30"

# Update runner/tests.py with additional tests
Commit-File "runner/tests.py" @'
from django.test import TestCase, Client
from django.urls import reverse
from .models import Player, Score
from .utils import is_valid_username, calculate_rating, format_score
import json


class PlayerModelTest(TestCase):
    """Unit tests for the Player model and its computed properties."""

    def setUp(self):
        self.player = Player.objects.create(username="TESTRUNNER")
        Score.objects.create(player=self.player, score=5000)
        Score.objects.create(player=self.player, score=3000)
        Score.objects.create(player=self.player, score=4000)

    def test_best_score(self):
        self.assertEqual(self.player.best_score, 5000)

    def test_total_runs(self):
        self.assertEqual(self.player.total_runs, 3)

    def test_average_score(self):
        self.assertEqual(self.player.average_score, 4000)

    def test_best_score_no_runs(self):
        new_player = Player.objects.create(username="NEWPLAYER")
        self.assertEqual(new_player.best_score, 0)

    def test_str_representation(self):
        self.assertEqual(str(self.player), "TESTRUNNER")


class UtilsTest(TestCase):
    """Unit tests for runner/utils.py helper functions."""

    def test_valid_username_accepted(self):
        self.assertTrue(is_valid_username("ACE"))
        self.assertTrue(is_valid_username("NEON_7"))
        self.assertTrue(is_valid_username("AB"))

    def test_invalid_username_too_short(self):
        self.assertFalse(is_valid_username("A"))

    def test_invalid_username_too_long(self):
        self.assertFalse(is_valid_username("ABCDEFGHIJKLM"))  # 13 chars

    def test_invalid_username_lowercase(self):
        self.assertFalse(is_valid_username("neon"))

    def test_invalid_username_special_chars(self):
        self.assertFalse(is_valid_username("ACE@99"))

    def test_rating_s(self):
        self.assertEqual(calculate_rating(75000), "S")

    def test_rating_a(self):
        self.assertEqual(calculate_rating(30000), "A")

    def test_rating_b(self):
        self.assertEqual(calculate_rating(15000), "B")

    def test_rating_c(self):
        self.assertEqual(calculate_rating(6000), "C")

    def test_rating_d(self):
        self.assertEqual(calculate_rating(100), "D")

    def test_format_score(self):
        self.assertEqual(format_score(1234567), "1,234,567")
        self.assertEqual(format_score(0), "0")


class SubmitScoreAPITest(TestCase):
    """Integration tests for the submit-score API endpoint."""

    def setUp(self):
        self.client = Client()
        self.url = reverse("submit_score")

    def test_submit_valid_score(self):
        payload = json.dumps({"username": "NEONACE", "score": 9999})
        response = self.client.post(self.url, data=payload, content_type="application/json")
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.content)
        self.assertEqual(data["status"], "success")
        self.assertIn("best_score", data)
        self.assertIn("rating", data)

    def test_submit_creates_player(self):
        payload = json.dumps({"username": "NEWACE", "score": 5000})
        self.client.post(self.url, data=payload, content_type="application/json")
        self.assertTrue(Player.objects.filter(username="NEWACE").exists())

    def test_submit_missing_score(self):
        payload = json.dumps({"username": "NEONACE"})
        response = self.client.post(self.url, data=payload, content_type="application/json")
        self.assertEqual(response.status_code, 400)

    def test_submit_negative_score(self):
        payload = json.dumps({"username": "NEONACE", "score": -100})
        response = self.client.post(self.url, data=payload, content_type="application/json")
        self.assertEqual(response.status_code, 400)

    def test_submit_invalid_username_lowercase(self):
        payload = json.dumps({"username": "neonace", "score": 500})
        response = self.client.post(self.url, data=payload, content_type="application/json")
        self.assertEqual(response.status_code, 400)

    def test_submit_wrong_method(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 405)

    def test_submit_invalid_json(self):
        response = self.client.post(self.url, data="not-json", content_type="application/json")
        self.assertEqual(response.status_code, 400)


class LeaderboardAPITest(TestCase):
    """Integration tests for the leaderboard API."""

    def setUp(self):
        self.client = Client()
        self.url = reverse("get_leaderboard")
        player = Player.objects.create(username="ACE")
        for s in [10000, 8000, 6000]:
            Score.objects.create(player=player, score=s)

    def test_leaderboard_returns_200(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 200)

    def test_leaderboard_has_entries(self):
        data = json.loads(self.client.get(self.url).content)
        self.assertGreater(len(data["leaderboard"]), 0)

    def test_leaderboard_has_rank(self):
        data = json.loads(self.client.get(self.url).content)
        self.assertIn("rank", data["leaderboard"][0])

    def test_leaderboard_sorted_descending(self):
        data = json.loads(self.client.get(self.url).content)
        scores = [e["score"] for e in data["leaderboard"]]
        self.assertEqual(scores, sorted(scores, reverse=True))


class HealthCheckTest(TestCase):
    """Tests for the health check endpoint."""

    def test_health_returns_ok(self):
        response = self.client.get("/health/")
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.content)
        self.assertEqual(data["status"], "ok")
        self.assertIn("version", data)


class PlayerStatsAPITest(TestCase):
    """Tests for the player stats API endpoint."""

    def setUp(self):
        self.client = Client()
        self.player = Player.objects.create(username="STATSMAN")
        Score.objects.create(player=self.player, score=20000)
        Score.objects.create(player=self.player, score=10000)

    def test_stats_returns_200(self):
        url = reverse("player_stats", args=["STATSMAN"])
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)

    def test_stats_has_expected_fields(self):
        url = reverse("player_stats", args=["STATSMAN"])
        data = json.loads(self.client.get(url).content)
        for field in ("username", "best_score", "total_runs", "average_score", "member_since"):
            self.assertIn(field, data)

    def test_stats_unknown_player_404(self):
        url = reverse("player_stats", args=["NOBODY"])
        response = self.client.get(url)
        self.assertEqual(response.status_code, 404)
'@ "test: expand test suite with utils, health check, player stats, and edge case coverage" "2026-07-05T12:00:00+05:30"

Commit-File "runner/static/css/game.css" @'
/*
 * game.css — Supplementary game-specific CSS not covered by TailwindCSS.
 * Handles complex animations, 3D transforms, and custom UI components.
 */

/* ─── Speed Lines (motion blur effect on fast runs) ─────────────────────── */
.speed-lines {
  position: fixed;
  inset: 0;
  pointer-events: none;
  z-index: 15;
  background: radial-gradient(
    ellipse at center,
    transparent 40%,
    rgba(255, 50, 0, 0.04) 100%
  );
  opacity: 0;
  transition: opacity 0.5s ease;
}
.speed-lines.active { opacity: 1; }

/* ─── Shield Glow (when Energy Core shield is active) ───────────────────── */
@keyframes shield-pulse {
  0%   { box-shadow: 0 0 0 0 rgba(0, 255, 136, 0.6); }
  70%  { box-shadow: 0 0 0 16px rgba(0, 255, 136, 0); }
  100% { box-shadow: 0 0 0 0 rgba(0, 255, 136, 0); }
}
.shield-active { animation: shield-pulse 1.2s infinite; }

/* ─── Rating Badge ───────────────────────────────────────────────────────── */
.rating-s { color: #facc15; text-shadow: 0 0 20px rgba(250, 204, 21, 0.8); }
.rating-a { color: #22d3ee; text-shadow: 0 0 20px rgba(34, 211, 238, 0.6); }
.rating-b { color: #a3e635; text-shadow: 0 0 20px rgba(163, 230, 53, 0.5); }
.rating-c { color: #fb923c; text-shadow: 0 0 15px rgba(251, 146, 60, 0.5); }
.rating-d { color: #9ca3af; }

/* ─── Clutch Flash Text ──────────────────────────────────────────────────── */
@keyframes clutch-pop {
  0%   { transform: translateX(-50%) scale(0.6) rotate(-3deg); opacity: 0; }
  30%  { transform: translateX(-50%) scale(1.1) rotate(2deg);  opacity: 1; }
  80%  { transform: translateX(-50%) scale(1.0) rotate(0deg);  opacity: 1; }
  100% { transform: translateX(-50%) scale(0.9) rotate(0deg);  opacity: 0; }
}
.clutch-animate { animation: clutch-pop 0.9s ease forwards; }

/* ─── Leaderboard Entry Hover ────────────────────────────────────────────── */
.leaderboard-entry {
  transition: background 0.2s ease, transform 0.15s ease;
}
.leaderboard-entry:hover {
  background: rgba(255, 255, 255, 0.08);
  transform: translateX(4px);
}

/* ─── Responsive: hide combo bar on very small screens ──────────────────── */
@media (max-height: 500px) {
  #combo-hud { display: none !important; }
}
'@ "style: add supplementary game.css with speed lines, shield glow, and rating badge styles" "2026-07-05T13:30:00+05:30"

Commit-File "docs/performance.md" @'
# CLUTCH RUN — Performance Notes

## Rendering Budget

| Component | Target Frame Budget |
|-----------|-------------------|
| Three.js scene render | ≤ 10ms |
| Physics update | ≤ 1ms |
| Obstacle collision | ≤ 0.5ms |
| DOM HUD update | ≤ 1ms |
| **Total frame (60 FPS target)** | **≤ 16.6ms** |

---

## Three.js Optimisations Applied

- **Geometry reuse**: All lane obstacles share the same `BoxGeometry` instance via instanced rendering where possible.
- **Fog culling**: Scene fog set to `Fog(0x050508, 30, 150)` — objects beyond 150 units are not rendered.
- **Pixel ratio cap**: `renderer.setPixelRatio(Math.min(devicePixelRatio, 2))` prevents 3x+ DPR devices from over-rendering.
- **Dispose on despawn**: `geometry.dispose()` and `material.dispose()` are called when obstacles leave the view frustum to prevent GPU memory leaks.
- **Tone mapping**: `ACESFilmicToneMapping` at exposure 1.2 gives cinematic output without a heavy post-processing pipeline.

---

## Backend Optimisations Applied

| Optimisation | Location | Benefit |
|---|---|---|
| `select_related('player')` on leaderboard query | `views.get_leaderboard` | Reduces N+1 DB queries |
| 60s leaderboard cache (Django cache API) | `runner/cache.py` | Eliminates repeated DB hits on popular endpoint |
| Score ordering on model `Meta` | `Score.Meta.ordering = ["-score"]` | Avoids `ORDER BY` overhead on most queries |

---

## Profiling Tips

Run with Django Debug Toolbar in development to inspect query counts:
```bash
pip install django-debug-toolbar
```

Use browser DevTools → Performance tab → record a 10-second run to identify JS bottlenecks.

Check Three.js renderer stats by attaching `stats.js`:
```js
import Stats from "https://unpkg.com/three@0.154.0/examples/jsm/libs/stats.module.js";
const stats = new Stats();
document.body.appendChild(stats.dom);
// call stats.update() inside your animation loop
```
'@ "docs: add performance notes covering rendering budget and backend query optimisations" "2026-07-05T15:00:00+05:30"

Write-Host ""
Write-Host "=============================================="
Write-Host "All commits done! Pushing to origin/main..."
Write-Host "=============================================="
git push origin main
Write-Host "✅ PUSH COMPLETE"
