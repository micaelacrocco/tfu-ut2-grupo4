#!/usr/bin/env bash
# Demo UT3: wallet_service es un servicio sin estado.
# El saldo vive en Postgres, no en memoria del proceso: matar y levantar de
# nuevo el contenedor no debe perder ni resetear ningún cambio ya aplicado.
set -e

echo "--- Saldo inicial del usuario 1 ---"
curl -s http://localhost:8001/api/v1/wallets/1; echo

echo "--- Debitando 250 ---"
curl -s -X POST http://localhost:8001/api/v1/wallets/transact \
  -H "Content-Type: application/json" \
  -d '{"user_id": 1, "amount": -250}'; echo

echo "--- Matando y recreando el contenedor de wallet_service (proceso nuevo, memoria vacía) ---"
docker compose kill wallet_service
docker compose up -d wallet_service
sleep 2

echo "--- Saldo luego de reiniciar el proceso ---"
curl -s http://localhost:8001/api/v1/wallets/1; echo
echo "El saldo refleja el débito aplicado antes del reinicio: el estado no"
echo "vivía en el proceso que murió, sino en Postgres. Cualquier réplica"
echo "nueva de wallet_service puede atender requests sin conocer historia previa."

echo "--- Restaurando saldo original del usuario 1 (10000) ---"
docker compose exec -T postgres_db bash -c \
  'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "UPDATE wallets SET balance = 10000.00 WHERE user_id = 1;"' \
  > /dev/null
