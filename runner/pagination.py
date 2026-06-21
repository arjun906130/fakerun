"""
pagination.py â€” Lightweight pagination helper for API list responses.

Provides a simple cursor-based page slicing utility so leaderboard
and score-history endpoints can support ?page= and ?page_size= query params
without requiring Django REST Framework.
"""

from django.http import JsonResponse

DEFAULT_PAGE_SIZE = 15
MAX_PAGE_SIZE = 50


def paginate_queryset(queryset, request):
    """
    Slices a queryset based on ?page and ?page_size query parameters.

    Args:
        queryset: Any Django queryset or list.
        request:  The current HttpRequest (used to read query params).

    Returns:
        A tuple of (page_items, pagination_meta_dict).
    """
    try:
        page = max(1, int(request.GET.get("page", 1)))
    except ValueError:
        page = 1

    try:
        page_size = min(MAX_PAGE_SIZE, max(1, int(request.GET.get("page_size", DEFAULT_PAGE_SIZE))))
    except ValueError:
        page_size = DEFAULT_PAGE_SIZE

    start = (page - 1) * page_size
    end   = start + page_size

    total = queryset.count() if hasattr(queryset, "count") else len(queryset)
    items = queryset[start:end]

    meta = {
        "page":       page,
        "page_size":  page_size,
        "total":      total,
        "has_next":   end < total,
        "has_prev":   page > 1,
    }
    return items, meta
