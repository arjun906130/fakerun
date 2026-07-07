from django.urls import path
from . import views
from .health import health_check

urlpatterns = [
    path("", views.index, name="index"),
    path("privacy/", views.privacy_policy, name="privacy_policy"),
    path("health/", health_check, name="health_check"),
    path("api/submit-score/", views.submit_score, name="submit_score"),
    path("api/leaderboard/", views.get_leaderboard, name="get_leaderboard"),
    path("api/player/<str:username>/stats/", views.get_player_stats, name="player_stats"),
    path("api/player/<str:username>/reset/", views.reset_scores, name="reset_scores"),
]
