"""
seed_scores.py
Django management command to populate the database with realistic dummy scores.
Useful for testing the leaderboard UI without manually submitting scores.

Usage:
    python manage.py seed_scores
    python manage.py seed_scores --count 50
"""

import random
from django.core.management.base import BaseCommand
from runner.models import Player, Score

SAMPLE_USERNAMES = [
    "NEON_ACE", "GRID_WOLF", "PHANTOM_X", "BLAZE_7", "VORTEX",
    "SHADOW_RUN", "KIRA_99", "APEX_REX", "ZENITH", "NOVA_Z",
]


class Command(BaseCommand):
    help = "Seeds the database with dummy players and scores for development/testing."

    def add_arguments(self, parser):
        parser.add_argument(
            "--count",
            type=int,
            default=20,
            help="Number of score records to generate (default: 20).",
        )

    def handle(self, *args, **options):
        count = options["count"]
        created = 0
        for _ in range(count):
            username = random.choice(SAMPLE_USERNAMES)
            player, _ = Player.objects.get_or_create(username=username)
            score_value = random.randint(500, 75_000)
            Score.objects.create(player=player, score=score_value)
            created += 1

        self.stdout.write(
            self.style.SUCCESS(f"Successfully seeded {created} score record(s) across {len(SAMPLE_USERNAMES)} players.")
        )
