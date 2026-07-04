# CLUTCH RUN â€” Game Design Document (GDD)

## Vision Statement
CLUTCH RUN is a high-intensity, cyberpunk endless runner where split-second reflexes and lane mastery determine survival. The game rewards precision with a cascading combo system while keeping runs short, replayable, and competitive through a live global leaderboard.

---

## Core Pillars

| Pillar | Design Goal |
|--------|-------------|
| **Speed Escalation** | Constant acceleration creates a mounting sense of danger |
| **Precision Rewards** | Near-miss CLUTCH events bonus-score skilled players |
| **Accessibility** | Keyboard + touch parity â€” no platform disadvantage |
| **Replayability** | Score-chasing against a global board drives return visits |

---

## Obstacle System

| Type | Colour | Avoidance |
|------|--------|-----------|
| Low Bar | ðŸ”´ Red | Player must **jump** |
| High Bar | ðŸ”¦ Cyan | Player must **slide** |
| Shard | ðŸŸ¡ Gold | Player must **change lane** |

---

## Scoring Formula

```
score_per_frame = BASE_SCORE_PER_SECOND Ã— multiplier Ã— current_speed Ã— dt
```

Clutch near-miss:
```
score += CLUTCH_BONUS Ã— multiplier
multiplier = min(10.0, 1.0 + combo Ã— 0.5)
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
- **Effect 1**: Shield â€” absorbs one collision
- **Effect 2**: Multiplier boost (Ã—2 for 5 seconds)
- **Visual**: Glowing green sphere with constant Y-rotation
