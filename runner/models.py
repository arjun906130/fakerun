from django.db import models


class Player(models.Model):
    username = models.CharField(max_length=100, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.username

    @property
    def best_score(self):
        """Returns the player's all-time highest score."""
        top = self.scores.order_by('-score').first()
        return top.score if top else 0

    @property
    def total_runs(self):
        """Returns the total number of runs the player has completed."""
        return self.scores.count()

    @property
    def average_score(self):
        """Returns the average score across all runs, rounded to the nearest integer."""
        count = self.scores.count()
        if count == 0:
            return 0
        total = sum(s.score for s in self.scores.all())
        return round(total / count)

    @property
    def total_distance(self):
        """Returns the sum of distance covered across all runs."""
        return sum(s.distance for s in self.scores.all())

    @property
    def highest_distance(self):
        """Returns the maximum distance achieved in a single run."""
        top = self.scores.order_by('-distance').first()
        return top.distance if top else 0

    @property
    def best_score_easy(self):
        """Returns the player's highest score on Easy difficulty."""
        top = self.scores.filter(difficulty='easy').order_by('-score').first()
        return top.score if top else 0

    @property
    def best_score_medium(self):
        """Returns the player's highest score on Medium difficulty."""
        top = self.scores.filter(difficulty='medium').order_by('-score').first()
        return top.score if top else 0

    @property
    def best_score_hard(self):
        """Returns the player's highest score on Hard difficulty."""
        top = self.scores.filter(difficulty='hard').order_by('-score').first()
        return top.score if top else 0

    @property
    def longest_streak(self):
        """Returns the longest consecutive run of scores >= 5000 (C-rating or above)."""
        scores = self.scores.order_by('timestamp').values_list('score', flat=True)
        best, current = 0, 0
        for s in scores:
            if s >= 5_000:
                current += 1
                best = max(best, current)
            else:
                current = 0
        return best

    @property
    def current_streak(self):
        """Returns the current consecutive run of scores >= 5000 from most recent backwards."""
        scores = self.scores.order_by('-timestamp').values_list('score', flat=True)
        streak = 0
        for s in scores:
            if s >= 5_000:
                streak += 1
            else:
                break
        return streak


class Score(models.Model):
    DIFFICULTY_CHOICES = [
        ('easy', 'Easy'),
        ('medium', 'Medium'),
        ('hard', 'Hard'),
    ]

    player = models.ForeignKey(Player, on_delete=models.CASCADE, related_name='scores')
    score = models.IntegerField()
    difficulty = models.CharField(
        max_length=10,
        choices=DIFFICULTY_CHOICES,
        default='medium',
        help_text='Difficulty preset selected for this run.',
    )
    distance = models.IntegerField(
        default=0,
        help_text='Total distance (metres) the player survived.',
    )
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-score']

    def __str__(self):
        return f"{self.player.username}: {self.score} ({self.difficulty})"
