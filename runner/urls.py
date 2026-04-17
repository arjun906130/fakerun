from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('api/submit-score/', views.submit_score, name='submit_score'),
    path('api/leaderboard/', views.get_leaderboard, name='get_leaderboard'),
]
