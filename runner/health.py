"""
health.py â€” Health check view for uptime monitoring and load balancer probes.

This endpoint returns a lightweight JSON response confirming the service is
running. It avoids touching the database to ensure it responds even during
heavy load or migration downtime.
"""

from django.http import JsonResponse
from django.conf import settings


def health_check(request):
    """
    Lightweight health probe endpoint.
    Returns HTTP 200 with service status and current game version.

    Does NOT query the database intentionally â€” this keeps the probe
    fast and ensures it passes even when the DB is under load.
    """
    return JsonResponse({
        "status": "ok",
        "version": getattr(settings, "GAME_VERSION", "1.4.0"),
        "service": "clutch-run",
    })
