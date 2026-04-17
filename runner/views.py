import json
from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .models import Player, Score

def index(request):
    return render(request, 'runner/index.html')

@csrf_exempt
def submit_score(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            username = data.get('username')
            score_value = data.get('score')
            
            if not username or score_value is None:
                return JsonResponse({'status': 'error', 'message': 'Missing data'}, status=400)
            
            player, created = Player.objects.get_or_create(username=username)
            Score.objects.create(player=player, score=score_value)
            
            return JsonResponse({'status': 'success'})
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)
    return JsonResponse({'status': 'error', 'message': 'Invalid method'}, status=405)

def get_leaderboard(request):
    top_scores = Score.objects.all()[:10]
    leaderboard = [
        {'username': score.player.username, 'score': score.score, 'timestamp': score.timestamp.strftime('%Y-%m-%d %H:%M')}
        for score in top_scores
    ]
    return JsonResponse({'leaderboard': leaderboard})
