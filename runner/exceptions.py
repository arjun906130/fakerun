"""
exceptions.py â€” Custom exception classes for the runner application.

Using domain-specific exceptions makes error handling explicit and allows
middleware or views to catch and respond to them uniformly.
"""


class RunnerBaseException(Exception):
    """Base class for all runner application exceptions."""
    default_message = "An unexpected runner error occurred."

    def __init__(self, message=None):
        self.message = message or self.default_message
        super().__init__(self.message)


class PlayerNotFoundException(RunnerBaseException):
    """Raised when a requested player username does not exist in the database."""
    default_message = "Player not found."


class InvalidScoreException(RunnerBaseException):
    """Raised when a submitted score value fails validation."""
    default_message = "The submitted score is invalid."


class InvalidUsernameException(RunnerBaseException):
    """Raised when a username does not meet the naming rules."""
    default_message = "The provided username is invalid."


class LeaderboardUnavailableException(RunnerBaseException):
    """Raised when the leaderboard cannot be fetched due to a backend error."""
    default_message = "The leaderboard is temporarily unavailable."
