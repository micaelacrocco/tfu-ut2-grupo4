"""Endpoints de negocio de ejemplo, controlados por config (RNF-01)."""

from fastapi import APIRouter, Depends, HTTPException

from app.config.loader import AppConfig, get_config

router = APIRouter()


@router.get("/greeting")
def greeting(config: AppConfig = Depends(get_config)):
    if not config.features.greeting_enabled:
        raise HTTPException(status_code=404, detail="greeting feature is disabled")

    message = config.business.greeting_message
    if config.business.mode == "formal":
        return {"message": f"Estimado usuario: {message}."}
    return {"message": f"{message}!"}
