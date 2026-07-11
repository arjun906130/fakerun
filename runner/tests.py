from django.test import TestCase, Client
from django.urls import reverse
from .models import Player, Score
from .utils import is_valid_username, calculate_rating, format_score
import json


class PlayerModelTest(TestCase):
    """Unit tests for the Player model and its computed properties."""

    def setUp(self):
        self.player = Player.objects.create(username="TESTRUNNER")
        Score.objects.create(player=self.player, score=5000, distance=300)
        Score.objects.create(player=self.player, score=3000, distance=150)
        Score.objects.create(player=self.player, score=4000, distance=200)

    def test_best_score(self):
        self.assertEqual(self.player.best_score, 5000)

    def test_total_runs(self):
        self.assertEqual(self.player.total_runs, 3)

    def test_average_score(self):
        self.assertEqual(self.player.average_score, 4000)

    def test_distance_properties(self):
        self.assertEqual(self.player.total_distance, 650)
        self.assertEqual(self.player.highest_distance, 300)

    def test_best_score_no_runs(self):
        new_player = Player.objects.create(username="NEWPLAYER")
        self.assertEqual(new_player.best_score, 0)

    def test_str_representation(self):
        self.assertEqual(str(self.player), "TESTRUNNER")


class UtilsTest(TestCase):
    """Unit tests for runner/utils.py helper functions."""

    def test_valid_username_accepted(self):
        self.assertTrue(is_valid_username("ACE"))
        self.assertTrue(is_valid_username("NEON_7"))
        self.assertTrue(is_valid_username("AB"))

    def test_invalid_username_too_short(self):
        self.assertFalse(is_valid_username("A"))

    def test_invalid_username_too_long(self):
        self.assertFalse(is_valid_username("ABCDEFGHIJKLM"))  # 13 chars

    def test_invalid_username_lowercase(self):
        self.assertFalse(is_valid_username("neon"))

    def test_invalid_username_special_chars(self):
        self.assertFalse(is_valid_username("ACE@99"))

    def test_rating_s(self):
        self.assertEqual(calculate_rating(75000), "S")

    def test_rating_a(self):
        self.assertEqual(calculate_rating(30000), "A")

    def test_rating_b(self):
        self.assertEqual(calculate_rating(15000), "B")

    def test_rating_c(self):
        self.assertEqual(calculate_rating(6000), "C")

    def test_rating_d(self):
        self.assertEqual(calculate_rating(100), "D")

    def test_format_score(self):
        self.assertEqual(format_score(1234567), "1,234,567")
        self.assertEqual(format_score(0), "0")


class SubmitScoreAPITest(TestCase):
    """Integration tests for the submit-score API endpoint."""

    def setUp(self):
        self.client = Client()
        self.url = reverse("submit_score")

    def test_submit_valid_score(self):
        payload = json.dumps({"username": "NEONACE", "score": 9999, "difficulty": "hard", "distance": 1200})
        response = self.client.post(self.url, data=payload, content_type="application/json")
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.content)
        self.assertEqual(data["status"], "success")
        self.assertIn("best_score", data)
        self.assertIn("rating", data)
        
        # Verify the saved score record has hard difficulty and 1200 distance
        score_record = Score.objects.filter(player__username="NEONACE").first()
        self.assertIsNotNone(score_record)
        self.assertEqual(score_record.score, 9999)
        self.assertEqual(score_record.difficulty, "hard")
        self.assertEqual(score_record.distance, 1200)

    def test_submit_creates_player(self):
        payload = json.dumps({"username": "NEWACE", "score": 5000})
        self.client.post(self.url, data=payload, content_type="application/json")
        self.assertTrue(Player.objects.filter(username="NEWACE").exists())
        score_record = Score.objects.filter(player__username="NEWACE").first()
        self.assertEqual(score_record.difficulty, "medium")  # default
        self.assertEqual(score_record.distance, 0)  # default

    def test_submit_missing_score(self):
        payload = json.dumps({"username": "NEONACE"})
        response = self.client.post(self.url, data=payload, content_type="application/json")
        self.assertEqual(response.status_code, 400)

    def test_submit_negative_score(self):
        payload = json.dumps({"username": "NEONACE", "score": -100})
        response = self.client.post(self.url, data=payload, content_type="application/json")
        self.assertEqual(response.status_code, 400)

    def test_submit_invalid_username_lowercase(self):
        payload = json.dumps({"username": "neonace", "score": 500})
        response = self.client.post(self.url, data=payload, content_type="application/json")
        self.assertEqual(response.status_code, 400)

    def test_submit_wrong_method(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 405)

    def test_submit_invalid_json(self):
        response = self.client.post(self.url, data="not-json", content_type="application/json")
        self.assertEqual(response.status_code, 400)


class LeaderboardAPITest(TestCase):
    """Integration tests for the leaderboard API."""

    def setUp(self):
        self.client = Client()
        self.url = reverse("get_leaderboard")
        player = Player.objects.create(username="ACE")
        for s in [10000, 8000, 6000]:
            Score.objects.create(player=player, score=s)

    def test_leaderboard_returns_200(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 200)

    def test_leaderboard_has_entries(self):
        data = json.loads(self.client.get(self.url).content)
        self.assertGreater(len(data["leaderboard"]), 0)

    def test_leaderboard_has_rank(self):
        data = json.loads(self.client.get(self.url).content)
        self.assertIn("rank", data["leaderboard"][0])

    def test_leaderboard_sorted_descending(self):
        data = json.loads(self.client.get(self.url).content)
        scores = [e["score"] for e in data["leaderboard"]]
        self.assertEqual(scores, sorted(scores, reverse=True))

    def test_leaderboard_filter_by_difficulty(self):
        player = Player.objects.create(username="DIFFPLAYER")
        Score.objects.create(player=player, score=15000, difficulty="hard")
        Score.objects.create(player=player, score=12000, difficulty="easy")
        
        response = self.client.get(self.url, {'difficulty': 'hard'})
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.content)
        
        scores = [e["score"] for e in data["leaderboard"]]
        self.assertIn(15000, scores)
        self.assertNotIn(12000, scores)


class HealthCheckTest(TestCase):
    """Tests for the health check endpoint."""

    def test_health_returns_ok(self):
        response = self.client.get("/health/")
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.content)
        self.assertEqual(data["status"], "ok")
        self.assertEqual(data["database"], "skipped")
        self.assertIn("version", data)

    def test_health_with_db_check_returns_ok(self):
        response = self.client.get("/health/", {"check_db": "true"})
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.content)
        self.assertEqual(data["status"], "ok")
        self.assertEqual(data["database"], "healthy")



class PlayerStatsAPITest(TestCase):
    """Tests for the player stats API endpoint."""

    def setUp(self):
        self.client = Client()
        self.player = Player.objects.create(username="STATSMAN")
        Score.objects.create(player=self.player, score=20000, difficulty="medium", distance=1500)
        Score.objects.create(player=self.player, score=10000, difficulty="easy", distance=800)
        Score.objects.create(player=self.player, score=30000, difficulty="hard", distance=2500)

    def test_stats_returns_200(self):
        url = reverse("player_stats", args=["STATSMAN"])
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)

    def test_stats_has_expected_fields(self):
        url = reverse("player_stats", args=["STATSMAN"])
        data = json.loads(self.client.get(url).content)
        for field in ("username", "best_score", "best_score_easy", "best_score_medium", "best_score_hard", "total_runs", "average_score", "total_distance", "highest_distance", "member_since"):
            self.assertIn(field, data)
        self.assertEqual(data["best_score_easy"], 10000)
        self.assertEqual(data["best_score_medium"], 20000)
        self.assertEqual(data["best_score_hard"], 30000)
        self.assertEqual(data["best_score"], 30000)
        self.assertEqual(data["total_distance"], 4800)
        self.assertEqual(data["highest_distance"], 2500)

    def test_stats_unknown_player_404(self):
        url = reverse("player_stats", args=["NOBODY"])
        response = self.client.get(url)
        self.assertEqual(response.status_code, 404)


class LeaderboardCacheTest(TestCase):
    """Unit tests for the leaderboard cache wrapper functions."""

    def setUp(self):
        from django.core.cache import cache
        cache.clear()

    def test_cache_set_and_get(self):
        from .cache import get_cached_leaderboard, set_cached_leaderboard
        dummy_data = [{'username': 'TEST1', 'score': 1000}]
        set_cached_leaderboard(dummy_data)
        self.assertEqual(get_cached_leaderboard(), dummy_data)

    def test_cache_set_and_get_difficulty(self):
        from .cache import get_cached_leaderboard, set_cached_leaderboard
        dummy_data = [{'username': 'TEST1', 'score': 1500}]
        set_cached_leaderboard(dummy_data, difficulty="hard")
        self.assertEqual(get_cached_leaderboard(difficulty="hard"), dummy_data)
        self.assertIsNone(get_cached_leaderboard())

    def test_cache_invalidation(self):
        from .cache import get_cached_leaderboard, set_cached_leaderboard, invalidate_leaderboard_cache
        dummy_data = [{'username': 'TEST1', 'score': 1000}]
        set_cached_leaderboard(dummy_data)
        set_cached_leaderboard(dummy_data, difficulty="hard")
        invalidate_leaderboard_cache()
        self.assertIsNone(get_cached_leaderboard())
        self.assertIsNone(get_cached_leaderboard(difficulty="hard"))

