# ⚡ CLUTCH RUN | High Intensity Reflex ⚡

An action-packed, web-based 3D endless runner game featuring high-end aesthetics, a custom neon rendering engine, and a live leaderboard database.

---

## 🌟 Key Features

*   **Custom 3D Engine**: Built on Three.js with advanced post-processing (Bloom, Noise, Grain).
*   **Procedural Generation**: Endless track and environment generation ensuring a unique run every time.
*   **Responsive Hybrid Controls**: Optimized for both Keyboard (WASD/Arrows) and Mobile Touch (Swipes).
*   **Live Leaderboard**: Real-time score tracking and persistent ranking system via Django.
*   **Audio immersion**: Dynamic sound engine that scales with game velocity.

---

## 🚀 Technologies Used

- **Frontend Core**: HTML5, Three.js (WebGL 3D Rendering & Bloom Post-processing), GSAP (Animations & Tweens)
- **Styling**: TailwindCSS, Glassmorphism, Custom CSS Keyframes
- **Backend Service**: Django (Python 3.x), Django REST API endpoints
- **Database**: SQLite3 (Player profile tracking & scoreboard logs)
- **Production Asset Delivery**: WhiteNoise Middleware

---

## 🕹️ Gameplay & Features

1. **High-Intensity Reflexes**: Navigate a retro-futuristic grid-world, dodging neon-lit obstacles.
2. **Dynamic Obstacles**:
   - **Low Bar (Red)**: Must be jumped over.
   - **High Bar (Cyan)**: Must be slid under.
   - **Shard Obstacles (Gold)**: Block lanes completely; must change lanes to avoid.
3. **Clutch Mechanic**: Navigating extremely close to obstacles without crashing awards a **CLUTCH!** near-miss bonus (+1,000 pts) and increments your score multiplier.
4. **Parallax Cityscape**: Procedurally generated cyber-skyscrapers that react dynamically and speed up over time.
5. **Power-ups (Energy Cores)**: Occasionally, bright green energy cores will appear. Collecting them grants a **Shield** (protects against one collision) and a **Multiplier Boost**.
6. **Scoreboard & Leaderboard**: Global high-score tracking submitted to a Django database, updated in real time.

---

## 🎮 Controls

| Action | Keyboard Controls | Touchscreen (Swipes) |
| :--- | :--- | :--- |
| **Move Left** | `A` or `Left Arrow` | Swipe Left |
| **Move Right** | `D` or `Right Arrow` | Swipe Right |
| **Jump** | `W` or `Up Arrow` | Swipe Up |
| **Slide** | `S` or `Down Arrow` | Swipe Down |

---

## 🛠️ Local Installation & Running Guide

### Prerequisites
Make sure you have Python 3.10+ installed on your system.

### 1. Install Dependencies
Navigate to the root directory and install requirements:
```bash
pip install -r requirements.txt
```

### 2. Prepare Databases & Assets
Apply database migrations:
```bash
python manage.py migrate
```

Gather static files (required because the project runs with `DEBUG = False` and WhiteNoise enabled):
```bash
python manage.py collectstatic --noinput
```

### 3. Run the Server
Launch the development server:
```bash
python manage.py runserver
```

Open your browser and play at **[http://127.0.0.1:8000/](http://127.0.0.1:8000/)**.

---

## 📁 Project Structure

```text
fakerun/
├── fakerun_project/    # Django Project configuration
├── runner/              # Main game application logic
│   ├── static/         # 3D Assets, JS modules, CSS
│   ├── templates/      # HTML entry point
│   ├── models.py       # Leaderboard database schemas
│   └── views.py        # API endpoints and page routing
├── staticfiles/        # Collected static assets for production
├── manage.py           # Django CLI
└── requirements.txt    # Project dependencies
```

