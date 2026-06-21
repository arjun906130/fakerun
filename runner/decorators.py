"""
decorators.py â€” Custom view decorators for the runner application.
"""

import functools
from django.http import JsonResponse


def require_json(view_func):
    """
    Decorator that enforces a JSON Content-Type on incoming requests.
    Returns 415 Unsupported Media Type if the content type is incorrect.
    """
    @functools.wraps(view_func)
    def wrapper(request, *args, **kwargs):
        content_type = request.content_type or ""
        if request.method in ("POST", "PUT", "PATCH") and "application/json" not in content_type:
            return JsonResponse(
                {"status": "error", "message": "Content-Type must be application/json"},
                status=415,
            )
        return view_func(request, *args, **kwargs)
    return wrapper


def log_request(view_func):
    """
    Decorator that logs the HTTP method and path for every call to the decorated view.
    """
    import logging
    logger = logging.getLogger(__name__)

    @functools.wraps(view_func)
    def wrapper(request, *args, **kwargs):
        logger.info("[%s] %s", request.method, request.path)
        return view_func(request, *args, **kwargs)
    return wrapper
