from django.apps import AppConfig


class RunnerConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'runner'
    verbose_name = 'Clutch Run'

    def ready(self):
        """
        Import signal handlers when the app is fully loaded.
        This ensures post_save / post_delete receivers are registered
        before any model operations occur.
        """
        import runner.signals  # noqa: F401
