# app/wallet_main.py

"""Arranque del Servicio de Wallet: sanity check -> config -> FastAPI (ACID) -> Uvicorn."""

import sys
from pathlib import Path

from fastapi import FastAPI

from app.aspects.logging_aspect import add_logging_aspect
from app.config.loader import build_config, load_raw_config
from app.config.validator import validate
from app.routers import wallet_router  # Router específico de cuentas y saldos

CONFIG_PATH = Path(__file__).parent.parent / "config" / "config.yaml"

raw_config = load_raw_config(CONFIG_PATH)
errors = validate(raw_config)
if errors:
    print("Configuración inválida en Wallet Service, el servicio no va a arrancar:")
    for error in errors:
        print(f"  - {error}")
    sys.exit(1)

config = build_config(raw_config)

app = FastAPI(title="InvestNow - Wallet Service (ACID Model)")
app.state.config = config

# Aplicar aspecto transversal de logging
add_logging_aspect(app, enabled=config.features.request_logging_enabled)

# Registrar rutas financieras de la wallet
app.include_router(wallet_router.router)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)