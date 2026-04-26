class AppError(Exception):
    """Base error for the python-service template."""


class RequestError(AppError):
    """HTTP request setup or transport failed."""


class SerializeError(AppError):
    """Response serialization failed."""


class ConfigError(AppError):
    """Config loading or validation failed."""
