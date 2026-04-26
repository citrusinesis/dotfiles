from __future__ import annotations

from pathlib import Path

import pytest

from python_service.config import Config
from python_service.errors import ConfigError


def test_from_path_loads_toml(tmp_path: Path) -> None:
    config_file = tmp_path / "config.toml"
    config_file.write_text(
        '[service]\nbase_url = "https://api.test"\ntimeout_seconds = 5\n',
        encoding="utf-8",
    )

    config = Config.from_path(config_file)

    assert config.service.base_url == "https://api.test"
    assert config.service.timeout_seconds == 5.0


def test_from_path_missing_raises(tmp_path: Path) -> None:
    with pytest.raises(ConfigError):
        Config.from_path(tmp_path / "missing.toml")


def test_with_overrides_applies_arguments() -> None:
    config = Config().with_overrides(base_url="https://override.test", log_level="DEBUG")

    assert config.service.base_url == "https://override.test"
    assert config.logging.level == "DEBUG"


def test_with_overrides_keeps_defaults_when_none() -> None:
    config = Config().with_overrides()

    assert config.service.base_url == "https://example.com"
