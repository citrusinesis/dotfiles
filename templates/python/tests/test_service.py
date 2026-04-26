from __future__ import annotations

import json

from python_service.service import HealthcheckResponse, ServiceClient


def test_example_response_ok() -> None:
    response = ServiceClient.example_response()

    assert response.ok is True


def test_serialize_round_trip() -> None:
    payload = ServiceClient.serialize(HealthcheckResponse(ok=True))

    assert json.loads(payload) == {"ok": True}
