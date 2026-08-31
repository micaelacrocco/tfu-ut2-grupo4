"""Endpoint de solo lectura para inspeccionar la config vigente (RNF-01)."""

from fastapi import APIRouter, Depends

from app.config.loader import AppConfig, get_config

router = APIRouter()


@router.get("/config")
def get_active_config(config: AppConfig = Depends(get_config)):
    return config
