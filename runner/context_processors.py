"""
context_processors.py
---------------------
Custom Django template context processors for the runner app.
These inject global variables available in every template rendered
by the runner application without explicitly passing them from each view.
"""

from django.conf import settings


def game_version(request):
    """
    Injects the current game version string into every template context.
    The value is read from settings.GAME_VERSION, falling back to 'v1.0.0'.

    Usage in templates:
        {{ game_version }}
    """
    return {
        'game_version': getattr(settings, 'GAME_VERSION', 'v1.0.0'),
    }


def debug_mode(request):
    """
    Exposes the DEBUG flag to templates so dev-only UI hints can be shown.

    Usage in templates:
        {% if debug_mode %} <debug-panel> {% endif %}
    """
    return {
        'debug_mode': settings.DEBUG,
    }


def site_meta(request):
    """
    Injects common site-wide metadata used in base templates.
    Centralises values like site name and canonical URL in one place.

    Usage in templates:
        {{ site_name }}, {{ canonical_url }}
    """
    return {
        'site_name': 'CLUTCH RUN',
        'canonical_url': getattr(settings, 'CANONICAL_URL', 'https://github.com/arjun906130/fakerun'),
    }
