from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/api/v1", tags=["Catalog Service"])

# Base de datos simulada en memoria para la demo
assets_db = {
    1: {"id": 1, "name": "Apple Inc.", "symbol": "AAPL", "status": "active"},
    2: {"id": 2, "name": "S&P 500 ETF", "symbol": "SPY", "status": "active"},
    3: {"id": 3, "name": "Tesla Inc.", "symbol": "TSLA", "status": "inactive"}
}

@router.get("/assets")
def get_assets():
    """I-CAT-01: Consulta pública del catálogo de activos."""
    return list(assets_db.values())

@router.patch("/assets/{asset_id}/status")
def update_asset_status(asset_id: int, status: str):
    """I-CAT-02: Interfaz de administración para habilitar/deshabilitar activos."""
    if asset_id not in assets_db:
        raise HTTPException(status_code=404, detail="Asset not found")
    if status not in ["active", "inactive"]:
        raise HTTPException(status_code=400, detail="Invalid status value")
    
    assets_db[asset_id]["status"] = status
    return {"message": "Status updated successfully", "asset": assets_db[asset_id]}