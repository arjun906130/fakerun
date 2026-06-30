import json
from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .models import Player, Score

def index(request):
    """
    Renders the main game page.
    """
    return render(request, 'runner/index.html')

@csrf_exempt
def submit_score(request):
    """
    API endpoint to submit a new score for a player.
    Creates player if they don't exist.
    """
    if request.method == 'POST':
        try:
            # Parse request body
            data = json.loads(request.body)
            username = data.get('username')
            score_value = data.get('score')
            
            # Validation
            if not username or score_value is None:
                return JsonResponse({'status': 'error', 'message': 'Missing data'}, status=400)
            
            # Atomic update or create player profile
            player, created = Player.objects.get_or_create(username=username)
            # Log the score entry
            Score.objects.create(player=player, score=score_value)
            
            return JsonResponse({'status': 'success'})
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)
    return JsonResponse({'status': 'error', 'message': 'Invalid method'}, status=405)

def get_leaderboard(request):
    """
    Retrieves the top 10 historical high scores.
    """
    # Fetch top 10 scores sorted by score value (assuming default ordering is handled in models or here)
    # Note: Score model should likely have an ordering meta-flag or use .order_by('-score')
    top_scores = Score.objects.all().order_by('-score')[:10]
    leaderboard = [
        {'username': score.player.username, 'score': score.score, 'timestamp': score.timestamp.strftime('%Y-%m-%d %H:%M')}
        for score in top_scores
    ]
    return JsonResponse({'leaderboard': leaderboard})

