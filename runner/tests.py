from django.test import TestCase, Client
from django.urls import reverse
from .models import Player, Score
import json


class PlayerModelTest(TestCase):
    """Unit tests for the Player model and its computed properties."""

    def setUp(self):
        self.player = Player.objects.create(username='TestRunner')
        Score.objects.create(player=self.player, score=5000)
        Score.objects.create(player=self.player, score=3000)
        Score.objects.create(player=self.player, score=4000)

    def test_best_score(self):
        """best_score property should return the player's highest score."""
        self.assertEqual(self.player.best_score, 5000)

    def test_total_runs(self):
        """total_runs property should return the correct count of score entries."""
        self.assertEqual(self.player.total_runs, 3)

    def test_average_score(self):
        """average_score property should return the rounded mean of all scores."""
        self.assertEqual(self.player.average_score, 4000)

    def test_best_score_no_runs(self):
        """best_score property should return 0 when no scores exist."""
        new_player = Player.objects.create(username='NewPlayer')
        self.assertEqual(new_player.best_score, 0)


class SubmitScoreAPITest(TestCase):
    """Integration tests for the submit-score API endpoint."""

    def setUp(self):
        self.client = Client()
        self.url = reverse('submit_score')

    def test_submit_valid_score(self):
        """A valid POST with username and score should return 200 and success status."""
        payload = json.dumps({'username': 'TestRunner', 'score': 9999})
        response = self.client.post(self.url, data=payload, content_type='application/json')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.content)
        self.assertEqual(data['status'], 'success')
        self.assertIn('best_score', data)

    def test_submit_missing_fields(self):
        """A POST missing score or username should return 400."""
        payload = json.dumps({'username': 'TestRunner'})
        response = self.client.post(self.url, data=payload, content_type='application/json')
        self.assertEqual(response.status_code, 400)

    def test_submit_negative_score(self):
        """A POST with a negative score should return 400."""
        payload = json.dumps({'username': 'TestRunner', 'score': -100})
        response = self.client.post(self.url, data=payload, content_type='application/json')
        self.assertEqual(response.status_code, 400)

    def test_submit_wrong_method(self):
        """A GET request to submit-score should return 405."""
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 405)


class LeaderboardAPITest(TestCase):
    """Integration tests for the leaderboard API endpoint."""

    def setUp(self):
        self.client = Client()
        self.url = reverse('get_leaderboard')
        player = Player.objects.create(username='Ace')
        for s in [10000, 8000, 6000]:
            Score.objects.create(player=player, score=s)

    def test_leaderboard_returns_scores(self):
        """Leaderboard should return a list containing leaderboard entries."""
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.content)
        self.assertIn('leaderboard', data)
        self.assertGreater(len(data['leaderboard']), 0)

    def test_leaderboard_has_rank(self):
        """Each leaderboard entry should include a rank field."""
        response = self.client.get(self.url)
        data = json.loads(response.content)
        self.assertIn('rank', data['leaderboard'][0])
