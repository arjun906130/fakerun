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


class Score(models.Model):
    player = models.ForeignKey(Player, on_delete=models.CASCADE, related_name='scores')
    score = models.IntegerField()
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-score']

    def __str__(self):
        return f"{self.player.username}: {self.score}"
