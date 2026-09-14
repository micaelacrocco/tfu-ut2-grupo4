from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter(prefix="/api/v1", tags=["Wallet Service"])

# Base de datos simulada en memoria (representando persistencia ACID)
wallets_db = {
    1: {"user_id": 1, "balance": 10000.00},
    2: {"user_id": 2, "balance": 500.00}
}

class TransactionRequest(BaseModel):
    user_id: int
    amount: float  # Positivo para depósito, negativo para débito/compra

@router.get("/wallets/{user_id}")
def get_wallet(user_id: int):
    """I-WAL-01: Consulta de saldo y portafolio del usuario."""
    if user_id not in wallets_db:
        raise HTTPException(status_code=404, detail="Wallet not found")
    return wallets_db[user_id]

@router.post("/wallets/transact")
def process_transaction(tx: TransactionRequest):
    """I-WAL-02: Transacción atómica ACID (bloqueo/mutación de saldo)."""
    if tx.user_id not in wallets_db:
        raise HTTPException(status_code=404, detail="Wallet not found")
    
    current_balance = wallets_db[tx.user_id]["balance"]
    
    # Validar consistencia estricta (no permitir saldo negativo)
    if current_balance + tx.amount < 0:
        raise HTTPException(status_code=400, detail="Insufficient funds. Transaction aborted (ACID violation prevention)")
    
    wallets_db[tx.user_id]["balance"] += tx.amount
    return {
        "status": "success",
        "user_id": tx.user_id,
        "previous_balance": current_balance,
        "new_balance": wallets_db[tx.user_id]["balance"]
    }