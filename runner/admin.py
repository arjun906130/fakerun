from django.contrib import admin
from .models import Player, Score


@admin.register(Player)
class PlayerAdmin(admin.ModelAdmin):
    list_display = ('username', 'created_at', 'get_best_score', 'get_total_runs')
    search_fields = ('username',)
    readonly_fields = ('created_at',)
    ordering = ('-created_at',)

    def get_best_score(self, obj):
        """Display the player's all-time best score."""
        best = obj.scores.order_by('-score').first()
        return best.score if best else 0
    get_best_score.short_description = 'Best Score'

    def get_total_runs(self, obj):
        """Display the total number of runs the player has attempted."""
        return obj.scores.count()
    get_total_runs.short_description = 'Total Runs'


@admin.register(Score)
class ScoreAdmin(admin.ModelAdmin):
    list_display = ('player', 'score', 'difficulty', 'distance', 'timestamp')
    list_filter = ('difficulty', 'timestamp', 'player')
    search_fields = ('player__username',)
    readonly_fields = ('timestamp',)
    ordering = ('-score',)
