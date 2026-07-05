# CLUTCH RUN â€” Performance Notes

## Rendering Budget

| Component | Target Frame Budget |
|-----------|-------------------|
| Three.js scene render | â‰¤ 10ms |
| Physics update | â‰¤ 1ms |
| Obstacle collision | â‰¤ 0.5ms |
| DOM HUD update | â‰¤ 1ms |
| **Total frame (60 FPS target)** | **â‰¤ 16.6ms** |

---

## Three.js Optimisations Applied

- **Geometry reuse**: All lane obstacles share the same `BoxGeometry` instance via instanced rendering where possible.
- **Fog culling**: Scene fog set to `Fog(0x050508, 30, 150)` â€” objects beyond 150 units are not rendered.
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

Use browser DevTools â†’ Performance tab â†’ record a 10-second run to identify JS bottlenecks.

Check Three.js renderer stats by attaching `stats.js`:
```js
import Stats from "https://unpkg.com/three@0.154.0/examples/jsm/libs/stats.module.js";
const stats = new Stats();
document.body.appendChild(stats.dom);
// call stats.update() inside your animation loop
```
