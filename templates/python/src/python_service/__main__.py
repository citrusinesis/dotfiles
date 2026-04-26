from __future__ import annotations

import argparse
import asyncio
import logging
import os
from pathlib import Path

from dotenv import load_dotenv

from python_service.config import Config
from python_service.errors import AppError
from python_service.service import ServiceClient

logger = logging.getLogger("python_service")


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="python-service template entrypoint")
    parser.add_argument(
        "--config",
        type=Path,
        default=Path("config.toml"),
        help="path to TOML config file",
    )
    parser.add_argument("--base-url", type=str, default=None)
    parser.add_argument("--timeout-seconds", type=float, default=None)
    parser.add_argument("--log-level", type=str, default=None)
    return parser.parse_args()


async def _run(config: Config) -> int:
    client = ServiceClient.from_config(config.service)
    try:
        response = client.example_response()
        payload = ServiceClient.serialize(response)
        print(f"template ready for {config.service.base_url}")
        print(payload)
    finally:
        await client.aclose()
    return 0


def main() -> int:
    load_dotenv()
    args = _parse_args()

    config = Config.from_path(args.config) if args.config.exists() else Config()
    config = config.with_overrides(
        base_url=args.base_url or os.getenv("SERVICE_BASE_URL"),
        timeout_seconds=(
            args.timeout_seconds
            if args.timeout_seconds is not None
            else (
                float(os.getenv("SERVICE_TIMEOUT_SECONDS", "0")) or None
                if os.getenv("SERVICE_TIMEOUT_SECONDS")
                else None
            )
        ),
        log_level=args.log_level or os.getenv("LOG_LEVEL"),
    )

    logging.basicConfig(level=config.logging.level)

    try:
        return asyncio.run(_run(config))
    except AppError as exc:
        logger.error("application error: %s", exc)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
