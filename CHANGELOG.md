# CHANGELOG

All notable changes to **CLUTCH RUN** are documented here.  
This project follows [Semantic Versioning](https://semver.org/).

---

## [1.4.0] — 2026-07-06

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
- Bumped in-game version badge from `V1.3.0` → `V1.4.0`.
- `submit_score` response now includes `best_score` and `total_runs` fields on success.
- Leaderboard JSON entries now include a `rank` field.

### Fixed
- `submit_score` now returns a meaningful 400 error when the JSON body cannot be parsed.

---

## [1.3.0] — 2026-07-02

### Added
- Combo multiplier system with on-screen HUD counter and decay timer.
- Session high-score badge ("NEW SECTOR RECORD") displayed during active run.
- Procedural sound engine scaling with game velocity.
- Dynamic screen-shake effect triggered on near-miss events.

### Changed
- Refactored obstacle generation to support shard-type lane blockers.
- Difficulty presets (Easy / Medium / Hard) now affect initial speed and obstacle density.

---

## [1.2.0] — 2026-07-01

### Added
- GSAP tween animations on main menu and game-over screen transitions.
- Scanline + scanline-light overlay for retro CRT aesthetic.
- `bg-glow` keyframe pulsing on main menu background.
- Sound toggle button in the HUD (`🔊`).

### Changed
- Leaderboard displays username, score, and formatted timestamp.
- Player model now uses `get_or_create` for atomic upserts.

---

## [1.1.0] — 2026-06-30

### Added
- Three.js WebGL 3D rendering engine with Bloom post-processing.
- Procedural neon-lit cityscape with parallax depth effect.
- Touch-swipe controls for mobile devices.
- CLUTCH near-miss detection (+1,000 pts bonus).

### Changed
- Replaced placeholder 2D canvas with full Three.js scene.

---

## [1.0.0] — 2026-06-24

### Added
- Initial Django project scaffold (`fakerun_project`, `runner` app).
- SQLite3 database with `Player` and `Score` models.
- REST API endpoints: `submit-score` and `leaderboard`.
- Basic HTML/CSS game UI with loading screen, HUD, and game-over screen.
- WhiteNoise static file serving for production deployment.
