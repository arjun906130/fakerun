# CLUTCH RUN â€” System Architecture

## Overview

CLUTCH RUN is a full-stack web application with a clear separation between the
game client (browser) and the backend service (Django).

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚        Browser Client        â”‚
â”‚  Three.js 3D Engine          â”‚
â”‚  GSAP Animation Layer        â”‚
â”‚  Web Audio API               â”‚
â”‚  api.js (fetch wrapper)      â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
             â”‚ HTTP (JSON)
             â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚     Django Web Server        â”‚
â”‚  WhiteNoise (static files)   â”‚
â”‚  runner/ application         â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚ views.py  (API layer) â”‚  â”‚
â”‚  â”‚ models.py (ORM)       â”‚  â”‚
â”‚  â”‚ utils.py  (helpers)   â”‚  â”‚
â”‚  â”‚ cache.py  (caching)   â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
             â”‚ Django ORM
             â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚        SQLite3 DB            â”‚
â”‚  runner_player               â”‚
â”‚  runner_score                â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| SQLite3 for storage | Zero-config, sufficient for game leaderboard scale |
| WhiteNoise for statics | Removes need for a separate CDN/Nginx in simple deployments |
| CSRF-exempt score API | Needed to support cross-origin game clients |
| Custom dict serializers | Avoids DRF dependency for a lightweight project |
| Leaderboard cache (60s TTL) | Reduces DB load on popular leaderboard endpoint |

## Data Flow â€” Score Submission

1. Game loop ends â†’ `api.js:submitScore(username, score)` is called.
2. POST request hits `/api/submit-score/`.
3. `views.submit_score` validates input via `utils.is_valid_username` and type checks.
4. `Player.objects.get_or_create(username=...)` ensures player exists atomically.
5. New `Score` record is created and `post_save` signal fires â†’ log entry written.
6. Leaderboard cache is invalidated.
7. Response returns `best_score`, `total_runs`, `rating`, `formatted_score`.
