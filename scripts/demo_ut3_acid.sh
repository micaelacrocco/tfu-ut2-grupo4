#!/usr/bin/env bash
# Demo UT3: transacción ACID real en wallet_service.
# El endpoint /wallets/transact hace SELECT ... FOR UPDATE dentro de una
# transacción de Postgres, así que débitos concurrentes sobre el mismo
# usuario se serializan: nunca se "pierde" un débito ni el saldo queda
# negativo, aunque las requests lleguen al mismo tiempo.
set -e

echo "--- Saldo inicial del usuario 2 ---"
curl -s http://localhost:8001/api/v1/wallets/2; echo

echo "--- Disparando 5 débitos concurrentes de 100 sobre el usuario 2 ---"
# El "&" al final de cada curl es lo que da la concurrencia: el for no
# espera a que termine una request para lanzar la siguiente, así que las 5
# corren como procesos en paralelo. "wait" solo sincroniza al final, para
# no leer el saldo antes de que las 5 hayan terminado.
TIMELINE=$(mktemp)
for i in 1 2 3 4 5; do
  (
    start_ms=$(($(date +%s%N) / 1000000))
    response=$(curl -s -X POST http://localhost:8001/api/v1/wallets/transact \
      -H "Content-Type: application/json" \
      -d '{"user_id": 2, "amount": -100}')
    end_ms=$(($(date +%s%N) / 1000000))
    echo "request $i: inicio=${start_ms}ms fin=${end_ms}ms respuesta=${response}" >> "$TIMELINE"
  ) &
done
wait
echo

echo "--- Timeline real de las 5 requests (para confirmar que se solaparon) ---"
sort -t= -k2 -n "$TIMELINE"
rm -f "$TIMELINE"

echo "--- Saldo final del usuario 2 ---"
curl -s http://localhost:8001/api/v1/wallets/2; echo
echo "El lock de fila (FOR UPDATE) garantiza que los 5 débitos se aplicaron"
echo "de a uno: el saldo final es consistente (nunca quedó negativo ni se"
echo "'perdió' ningún débito por una condición de carrera)."

echo "--- Restaurando saldo original del usuario 2 (500) ---"
docker compose exec -T postgres_db bash -c \
  'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "UPDATE wallets SET balance = 500.00 WHERE user_id = 2;"' \
  > /dev/null
