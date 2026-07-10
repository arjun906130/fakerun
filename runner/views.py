import json
from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from .models import Player, Score
from .utils import is_valid_username, calculate_rating, format_score


def index(request):
    """
    Renders the main game page.
    """
    return render(request, 'runner/index.html')


def privacy_policy(request):
    """
    Renders the privacy policy page.
    """
    return render(request, 'runner/privacy.html')


@require_http_methods(["GET"])
def robots_txt(request):
    """
    Serves the robots.txt file as a plain text response.
    """
    content = "User-agent: *\nDisallow: /api/\nDisallow: /admin/\nAllow: /"
    return HttpResponse(content, content_type="text/plain")


@csrf_exempt
def submit_score(request):
    """
    API endpoint to submit a new score for a player.
    Creates the player profile if they do not already exist.
    """
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            username = data.get('username', '').strip()
            score_value = data.get('score')

            # Validation: require both fields
            if not username or score_value is None:
                return JsonResponse({'status': 'error', 'message': 'Missing username or score'}, status=400)

            # Validate username format (uppercase alphanumeric + underscore, 2–12 chars)
            if not is_valid_username(username):
                return JsonResponse(
                    {'status': 'error', 'message': 'Username must be 2–12 uppercase letters, digits, or underscores'},
                    status=400
                )

            # Validate score is a non-negative integer
            if not isinstance(score_value, int) or score_value < 0:
                return JsonResponse({'status': 'error', 'message': 'Score must be a non-negative integer'}, status=400)

            # Extract and validate optional difficulty and distance parameters
            difficulty = data.get('difficulty', 'medium')
            if difficulty not in ['easy', 'medium', 'hard']:
                difficulty = 'medium'
            
            distance = data.get('distance', 0)
            if not isinstance(distance, int) or distance < 0:
                distance = 0

            # Atomic get-or-create player profile, then log the score
            player, _ = Player.objects.get_or_create(username=username)
            Score.objects.create(player=player, score=score_value, difficulty=difficulty, distance=distance)

            return JsonResponse({
                'status': 'success',
                'best_score': player.best_score,
                'total_runs': player.total_runs,
                'rating': calculate_rating(score_value),
                'formatted_score': format_score(score_value),
            })
        except json.JSONDecodeError:
            return JsonResponse({'status': 'error', 'message': 'Invalid JSON body'}, status=400)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)

    return JsonResponse({'status': 'error', 'message': 'Method not allowed'}, status=405)


def get_leaderboard(request):
    """
    Retrieves the top 15 all-time high scores for the global leaderboard.
    Optionally filters by difficulty.
    Returns a JSON response with username, score, and formatted timestamp.
    """
    difficulty = request.GET.get('difficulty')
    queryset = Score.objects.select_related('player')
    if difficulty in ['easy', 'medium', 'hard']:
        queryset = queryset.filter(difficulty=difficulty)
    
    top_scores = queryset.order_by('-score')[:15]
    leaderboard = [
        {
            'rank': idx + 1,
            'username': score.player.username,
            'score': score.score,
            'difficulty': score.difficulty,
            'distance': score.distance,
            'timestamp': score.timestamp.strftime('%Y-%m-%d %H:%M'),
        }
        for idx, score in enumerate(top_scores)
    ]
    return JsonResponse({'leaderboard': leaderboard})


@csrf_exempt
@require_http_methods(["DELETE"])
def reset_scores(request, username):
    """
    API endpoint to delete all score records for a specific player.
    Allows a player to wipe their history and start fresh.
    """
    try:
        player = Player.objects.get(username=username)
        deleted_count, _ = player.scores.all().delete()
        return JsonResponse({'status': 'success', 'deleted': deleted_count})
    except Player.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Player not found'}, status=404)
    except Exception as e:
        return JsonResponse({'status': 'error', 'message': str(e)}, status=500)


def get_player_stats(request, username):
    """
    API endpoint to retrieve aggregated statistics for a specific player.
    Returns best score, total runs, and average score.
    """
    try:
        player = Player.objects.get(username=username)
        return JsonResponse({
            'username': player.username,
            'best_score': player.best_score,
            'total_runs': player.total_runs,
            'average_score': player.average_score,
            'member_since': player.created_at.strftime('%Y-%m-%d'),
        })
    except Player.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Player not found'}, status=404)
