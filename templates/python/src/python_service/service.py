from __future__ import annotations

import json
from dataclasses import asdict, dataclass

import httpx

from python_service.config import ServiceConfig
from python_service.errors import RequestError, SerializeError


@dataclass(frozen=True)
class HealthcheckResponse:
    ok: bool


class ServiceClient:
    def __init__(self, config: ServiceConfig, client: httpx.AsyncClient) -> None:
        self._config = config
        self._client = client

    @classmethod
    def from_config(cls, config: ServiceConfig) -> ServiceClient:
        try:
            client = httpx.AsyncClient(
                base_url=config.base_url.rstrip("/"),
                timeout=config.timeout_seconds,
            )
        except httpx.HTTPError as exc:
            raise RequestError(f"failed to build http client: {exc}") from exc
        return cls(config, client)

    async def aclose(self) -> None:
        await self._client.aclose()

    async def healthcheck(self) -> HealthcheckResponse:
        try:
            response = await self._client.get("/health")
            response.raise_for_status()
        except httpx.HTTPError as exc:
            raise RequestError(f"healthcheck request failed: {exc}") from exc

        try:
            payload = response.json()
        except json.JSONDecodeError as exc:
            raise SerializeError(f"failed to decode response: {exc}") from exc

        return HealthcheckResponse(ok=bool(payload.get("ok", False)))

    @staticmethod
    def example_response() -> HealthcheckResponse:
        return HealthcheckResponse(ok=True)

    @staticmethod
    def serialize(response: HealthcheckResponse) -> str:
        try:
            return json.dumps(asdict(response))
        except (TypeError, ValueError) as exc:
            raise SerializeError(f"failed to serialize response: {exc}") from exc
