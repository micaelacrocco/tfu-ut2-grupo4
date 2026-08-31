"""Aspecto transversal de logging de requests, aislado de los endpoints (RNF-02)."""

import time

from fastapi import FastAPI


def add_logging_aspect(app: FastAPI, enabled: bool) -> None:
    if not enabled:
        return

    @app.middleware("http")
    async def log_requests(request, call_next):
        start = time.monotonic()
        response = await call_next(request)
        duration_ms = (time.monotonic() - start) * 1000
        print(
            f"{request.method} {request.url.path} "
            f"status={response.status_code} duration_ms={duration_ms:.1f}"
        )
        return response
