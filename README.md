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

Open your browser and play at **[http://127.0.0.1:8000/](http://127.0.0.1:8000/)**.

---

## ☁️ Deployment (Render)

1. Push the repository to GitHub.
2. Log in to [Render](https://render.com) and create a new **Web Service**.
3. Connect your GitHub repository and select the branch to deploy.
4. Set the following configuration in Render's dashboard:

| Setting | Value |
| :--- | :--- |
| **Build Command** | `pip install -r requirements.txt && python manage.py collectstatic --noinput && python manage.py migrate` |
| **Start Command** | `gunicorn fakerun_project.wsgi:application` |
| **Python Version** | `3.10` |

5. Add the following **Environment Variables** in the Render dashboard (see `.env.example` for reference):
   - `DJANGO_SECRET_KEY` — A strong, unique secret key.
   - `DJANGO_DEBUG` — Set to `False`.
   - `DJANGO_ALLOWED_HOSTS` — Your Render app hostname (e.g., `clutchrun.onrender.com`).
6. Click **Deploy**. Your game will be live within minutes.

---

## 🌐 REST API Reference

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/leaderboard/` | Returns the top 15 all-time high scores |
| `POST` | `/api/submit-score/` | Submits a new score for a player |
| `GET` | `/api/player/<username>/stats/` | Returns aggregated stats for a player |
| `DELETE` | `/api/player/<username>/reset/` | Wipes all score records for a player |

---

## 🤝 Contributing

Contributions are welcome! To get started:

1. Fork the repository and create a new feature branch (`git checkout -b feat/my-feature`).
2. Copy `.env.example` to `.env` and fill in your local values.
3. Install dependencies and run migrations (see Local Installation above).
4. Make your changes with clear, descriptive commits.
5. Open a Pull Request describing what you changed and why.

Please ensure all new API endpoints include appropriate docstrings and error handling.

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
├── .env.example        # Environment variable template
├── CHANGELOG.md        # Version history
├── manage.py           # Django CLI
└── requirements.txt    # Project dependencies
```
