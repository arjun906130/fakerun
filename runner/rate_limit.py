"""
rate_limit.py
-------------
Simple in-memory rate limiter for API endpoints.
Limits the number of requests from a single IP within a sliding window.
"""

import time
from collections import defaultdict
from django.http import JsonResponse


class RateLimitMiddleware:
    """
    Middleware that enforces rate limiting on API endpoints.

    Tracks request counts per IP using an in-memory sliding window.
    Non-API paths (e.g. the game page, static files) are excluded from limiting.

    Configuration:
        MAX_REQUESTS: Maximum number of API calls allowed per window.
        WINDOW_SECONDS: Length of the sliding window in seconds.
    """

    MAX_REQUESTS = 60
    WINDOW_SECONDS = 60

    def __init__(self, get_response):
        self.get_response = get_response
        self._hits = defaultdict(list)  # ip -> [timestamp, ...]

    def __call__(self, request):
        # Only rate-limit API routes
        if not request.path.startswith("/api/"):
            return self.get_response(request)

        ip = self._get_client_ip(request)
        now = time.monotonic()
        cutoff = now - self.WINDOW_SECONDS

        # Purge expired timestamps
        self._hits[ip] = [t for t in self._hits[ip] if t > cutoff]

        if len(self._hits[ip]) >= self.MAX_REQUESTS:
            return JsonResponse(
                {
                    "status": "error",
                    "message": "Rate limit exceeded. Try again later.",
                },
                status=429,
            )

        self._hits[ip].append(now)
        response = self.get_response(request)
        response["X-RateLimit-Limit"] = str(self.MAX_REQUESTS)
        response["X-RateLimit-Remaining"] = str(
            self.MAX_REQUESTS - len(self._hits[ip])
        )
        return response

    @staticmethod
    def _get_client_ip(request):
        """Extract the originating IP, respecting X-Forwarded-For when present."""
        forwarded = request.META.get("HTTP_X_FORWARDED_FOR")
        if forwarded:
            return forwarded.split(",")[0].strip()
        return request.META.get("REMOTE_ADDR", "unknown")
