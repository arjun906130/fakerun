# CLUTCH RUN â€” REST API Reference

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
