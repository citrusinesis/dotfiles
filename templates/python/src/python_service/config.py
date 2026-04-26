from __future__ import annotations

import logging
import os
import tomllib
from dataclasses import dataclass, field, replace
from pathlib import Path
from typing import Any

from python_service.errors import ConfigError

logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class ServiceConfig:
    base_url: str = "https://example.com"
    timeout_seconds: float = 10.0


@dataclass(frozen=True)
class LoggingConfig:
    level: str = "INFO"


@dataclass(frozen=True)
class Config:
    service: ServiceConfig = field(default_factory=ServiceConfig)
    logging: LoggingConfig = field(default_factory=LoggingConfig)

    @classmethod
    def from_path(cls, path: str | os.PathLike[str]) -> Config:
        config_path = Path(path)
        if not config_path.exists():
            raise ConfigError(f"config file not found: {config_path}")

        try:
            raw = tomllib.loads(config_path.read_text(encoding="utf-8"))
        except tomllib.TOMLDecodeError as exc:
            raise ConfigError(f"failed to parse {config_path}: {exc}") from exc

        return cls.from_mapping(raw)

    @classmethod
    def from_mapping(cls, data: dict[str, Any]) -> Config:
        service = data.get("service", {})
        log = data.get("logging", {})
        return cls(
            service=ServiceConfig(
                base_url=str(service.get("base_url", ServiceConfig.base_url)),
                timeout_seconds=float(
                    service.get("timeout_seconds", ServiceConfig.timeout_seconds)
                ),
            ),
            logging=LoggingConfig(
                level=str(log.get("level", LoggingConfig.level)),
            ),
        )

    def with_overrides(
        self,
        *,
        base_url: str | None = None,
        timeout_seconds: float | None = None,
        log_level: str | None = None,
    ) -> Config:
        service = self.service
        if base_url is not None:
            service = replace(service, base_url=base_url)
        if timeout_seconds is not None:
            service = replace(service, timeout_seconds=timeout_seconds)

        log = self.logging
        if log_level is not None:
            log = replace(log, level=log_level)

        merged = replace(self, service=service, logging=log)
        logger.info("resolved config: %s", merged)
        return merged
