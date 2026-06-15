"""
reset_leaderboard.py
Django management command to wipe all Score records from the database.
Useful for resetting the leaderboard during development or testing.

Usage:
    python manage.py reset_leaderboard
    python manage.py reset_leaderboard --confirm
"""

from django.core.management.base import BaseCommand
from runner.models import Score


class Command(BaseCommand):
    help = "Deletes all Score records, effectively resetting the global leaderboard."

    def add_arguments(self, parser):
        parser.add_argument(
            "--confirm",
            action="store_true",
            help="Skip the interactive confirmation prompt.",
        )

    def handle(self, *args, **options):
        if not options["confirm"]:
            answer = input("This will DELETE all leaderboard scores. Are you sure? [y/N] ")
            if answer.lower() != "y":
                self.stdout.write(self.style.WARNING("Aborted. No records were deleted."))
                return

        count, _ = Score.objects.all().delete()
        self.stdout.write(
            self.style.SUCCESS(f"Successfully deleted {count} score record(s).")
        )
