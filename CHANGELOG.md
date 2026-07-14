## [1.8.0] — 2026-07-14

### Added
- Win-streak tracking on the Player model: `longest_streak` and `current_streak` computed properties.
- Streak data exposed in `/api/player/<username>/stats/` response and player serializer.
- Unit tests for streak properties covering active streaks, broken streaks, and edge cases.

### Changed
- Bumped terminal version indicator to v1.8.0.

---

## [1.7.6] — 2026-07-13

### Added
- Total Survival Distance and Maximum Run Distance metrics to pilot dossier stats panel.
- API support for forwarding aggregate player distance metrics in stats responses.

### Changed
- Updated client-side stats controller to bind and render distance metrics dynamically.
- Bumped terminal version indicator to v1.7.6.

---

## [1.6.0] â€” 2026-07-07

### Added
- Rate limiting middleware (`runner/rate_limit.py`) enforcing 60 req/min per IP on API endpoints.
- `difficulty` and `distance` fields to the `Score` model for granular run tracking.
- `total_distance` and `highest_distance` properties on the `Player` model.
- Dedicated Privacy Policy page (`/privacy/`) and template.
- Search engine optimization with `robots.txt` endpoint.
- Support for environment variables in `settings.py` (`DJANGO_SECRET_KEY`, `DJANGO_DEBUG`, `DJANGO_ALLOWED_HOSTS`).
- New CSS animations in `game.css`: game-over screen entrance, death burst particles, and score counting glow.

### Changed
- Bumped in-game version badge to `V1.6.0`.
- Sanitized `ALLOWED_HOSTS` to load from comma-separated environment string.

---

## [1.5.0] â€” 2026-07-04

### Added
- `runner/constants.py` â€” centralised game-wide constant values.
- `runner/validators.py` â€” custom Django field validators for username and score.
- `runner/exceptions.py` â€” domain-specific exception hierarchy.
- `runner/cache.py` â€” leaderboard caching with 60s TTL and cache invalidation helper.
- `runner/decorators.py` â€” `require_json` and `log_request` view decorators.
- `runner/pagination.py` â€” lightweight cursor-based pagination helper.
- `runner/serializers.py` â€” dict serializers for Score and Player model instances.
- `runner/health.py` + `/health/` URL â€” uptime monitoring endpoint.
- Management commands: `reset_leaderboard`, `seed_scores`.
- Template filters: `format_score`, `rating`, `rank_badge` in `runner/templatetags/`.
- JS modules: `audio.js`, `controls.js`, `physics.js`, `obstacles.js`, `environment.js`, `player.js`, `score.js`, `hud.js`, `effects.js`, `powerups.js`, `menu.js`, `loader.js`, `renderer.js`, `touch.js`, `settings.js`, `api.js`.
- `render.yaml` for one-click Render deployment.
- `Makefile` with common dev workflow shortcuts.
- `runtime.txt` specifying Python 3.11.9.
- `.github/workflows/ci.yml` â€” GitHub Actions CI for automated testing.
- `.github/ISSUE_TEMPLATE/` â€” bug report and feature request templates.
- `docs/api.md`, `docs/architecture.md`, `docs/game_design.md`.
- `SECURITY.md` â€” vulnerability reporting policy.

### Changed
- `requirements.txt` â€” pinned all dependency version ranges.
- Health check route added to `runner/urls.py`.
# CHANGELOG

All notable changes to **CLUTCH RUN** are documented here.  
This project follows [Semantic Versioning](https://semver.org/).

---

## [1.4.0] â€” 2026-07-06

### Added
- `get_player_stats` API endpoint (`/api/player/<username>/stats/`) returning best score, total runs, average score, and member-since date.
- `reset_scores` API endpoint (`/api/player/<username>/reset/`) allowing players to wipe their score history via a `DELETE` request.
- `best_score`, `total_runs`, and `average_score` computed properties on the `Player` model.
- Fully registered `Player` and `Score` models in Django Admin with computed columns (Best Score, Total Runs), search, and filtering.
- Leaderboard now returns top 15 scores (up from 10) with rank field included in the JSON response.
- Input validation in `submit_score`: rejects non-integer and negative scores with descriptive error messages.
- `select_related` optimisation on leaderboard query to reduce DB round-trips.
- Open Graph and Twitter Card meta tags in `index.html` for richer social media sharing previews.
- `.env.example` template to guide contributors in setting up environment variables.

### Changed
- Bumped in-game version badge from `V1.3.0` â†’ `V1.4.0`.
- `submit_score` response now includes `best_score` and `total_runs` fields on success.
- Leaderboard JSON entries now include a `rank` field.

### Fixed
- `submit_score` now returns a meaningful 400 error when the JSON body cannot be parsed.

---

## [1.3.0] â€” 2026-07-02

### Added
- Combo multiplier system with on-screen HUD counter and decay timer.
- Session high-score badge ("NEW SECTOR RECORD") displayed during active run.
- Procedural sound engine scaling with game velocity.
- Dynamic screen-shake effect triggered on near-miss events.

### Changed
- Refactored obstacle generation to support shard-type lane blockers.
- Difficulty presets (Easy / Medium / Hard) now affect initial speed and obstacle density.

---

## [1.2.0] â€” 2026-07-01

### Added
- GSAP tween animations on main menu and game-over screen transitions.
- Scanline + scanline-light overlay for retro CRT aesthetic.
- `bg-glow` keyframe pulsing on main menu background.
- Sound toggle button in the HUD (`ðŸ”Š`).

### Changed
- Leaderboard displays username, score, and formatted timestamp.
- Player model now uses `get_or_create` for atomic upserts.

---

## [1.1.0] â€” 2026-06-30

### Added
- Three.js WebGL 3D rendering engine with Bloom post-processing.
- Procedural neon-lit cityscape with parallax depth effect.
- Touch-swipe controls for mobile devices.
- CLUTCH near-miss detection (+1,000 pts bonus).

### Changed
- Replaced placeholder 2D canvas with full Three.js scene.

---

## [1.0.0] â€” 2026-06-24

### Added
- Initial Django project scaffold (`fakerun_project`, `runner` app).
- SQLite3 database with `Player` and `Score` models.
- REST API endpoints: `submit-score` and `leaderboard`.
- Basic HTML/CSS game UI with loading screen, HUD, and game-over screen.
- WhiteNoise static file serving for production deployment.

