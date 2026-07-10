"""
health.py â€” Health check view for uptime monitoring and load balancer probes.

This endpoint returns a lightweight JSON response confirming the service is
running. It avoids touching the database to ensure it responds even during
heavy load or migration downtime.
"""

from django.http import JsonResponse
from django.conf import settings
from django.db import connection


def health_check(request):
    """
    Lightweight health probe endpoint.
    Returns HTTP 200 with service status and current game version.
    Optionally performs a quick database check if `check_db=true`.
    """
    db_status = "skipped"
    check_db = request.GET.get("check_db", "false").lower() == "true"
    
    if check_db:
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
                cursor.fetchone()
            db_status = "healthy"
        except Exception as e:
            return JsonResponse({
                "status": "error",
                "database": "unhealthy",
                "detail": str(e),
                "version": getattr(settings, "GAME_VERSION", "1.4.0"),
                "service": "clutch-run",
            }, status=503)

    return JsonResponse({
        "status": "ok",
        "database": db_status,
        "version": getattr(settings, "GAME_VERSION", "1.4.0"),
        "service": "clutch-run",
    })
