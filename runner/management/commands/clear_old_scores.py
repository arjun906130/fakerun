from django.core.management.base import BaseCommand
from runner.models import Score
from datetime import timedelta
from django.utils import timezone

class Command(BaseCommand):
    help = 'Deletes scores that are older than 30 days and below 10,000 points.'

    def handle(self, *args, **options):
        cutoff_date = timezone.now() - timedelta(days=30)
        threshold = 10000
        
        old_scores = Score.objects.filter(
            timestamp__lt=cutoff_date,
            score__lt=threshold
        )
        
        count = old_scores.count()
        old_scores.delete()
        
        self.stdout.write(
            self.style.SUCCESS(f'Successfully deleted {count} old low-score records.')
        )
