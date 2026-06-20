"""
signals.py
----------
Django signals for the runner application.
Signals allow decoupled components to react to model lifecycle events
without tightly coupling the logic inside the model itself.
"""

import logging
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from .models import Score, Player

logger = logging.getLogger(__name__)


@receiver(post_save, sender=Score)
def log_new_score(sender, instance, created, **kwargs):
    """
    Fires after a Score record is saved.
    Logs a message when a new score entry is created, including whether
    it is the player's current all-time best.
    """
    if created:
        is_best = instance.score >= instance.player.best_score
        logger.info(
            "New score submitted — player: %s | score: %s | personal best: %s",
            instance.player.username,
            instance.score,
            "YES" if is_best else "NO",
        )


@receiver(post_delete, sender=Player)
def log_player_deleted(sender, instance, **kwargs):
    """
    Fires after a Player record is deleted from the database.
    Logs a warning so administrators can track account removals.
    """
    logger.warning(
        "Player account deleted — username: %s", instance.username
    )
