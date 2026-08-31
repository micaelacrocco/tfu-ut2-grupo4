"""Carga la configuración externa y la expone como objeto tipado (RNF-01)."""

from pathlib import Path

import yaml
from fastapi import Request
from pydantic import BaseModel


class ServerConfig(BaseModel):
    port: int


class FeaturesConfig(BaseModel):
    greeting_enabled: bool
    request_logging_enabled: bool


class BusinessConfig(BaseModel):
    greeting_message: str
    mode: str


class AppConfig(BaseModel):
    server: ServerConfig
    features: FeaturesConfig
    business: BusinessConfig


def load_raw_config(path: Path) -> dict:
    with open(path, encoding="utf-8") as f:
        return yaml.safe_load(f)


def build_config(raw: dict) -> AppConfig:
    return AppConfig.model_validate(raw)


def get_config(request: Request) -> AppConfig:
    return request.app.state.config
