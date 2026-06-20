import time
import logging

logger = logging.getLogger(__name__)


class RequestTimingMiddleware:
    """
    Middleware that logs the processing time for every incoming HTTP request.
    Useful for identifying slow endpoints during development and production monitoring.
    """

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        start_time = time.monotonic()

        response = self.get_response(request)

        duration_ms = (time.monotonic() - start_time) * 1000
        logger.info(
            "[%s] %s %s — %.2f ms",
            response.status_code,
            request.method,
            request.path,
            duration_ms,
        )

        # Attach timing header for debugging convenience
        response["X-Response-Time-Ms"] = f"{duration_ms:.2f}"
        return response


class SecurityHeadersMiddleware:
    """
    Middleware that injects standard security response headers on every request.
    Complements Django's built-in SecurityMiddleware with additional hardening.
    """

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)

        # Prevent MIME-type sniffing
        response.setdefault("X-Content-Type-Options", "nosniff")
        # Basic XSS protection for older browsers
        response.setdefault("X-XSS-Protection", "1; mode=block")
        # Restrict referrer info sent to third parties
        response.setdefault("Referrer-Policy", "strict-origin-when-cross-origin")
        # Disallow embedding in iframes from other origins
        response.setdefault("X-Frame-Options", "DENY")

        return response
