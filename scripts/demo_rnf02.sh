#!/usr/bin/env bash
# Demo RNF-02: aspecto de logging, activable/desactivable por config.
set -e

CONFIG=app/config/config.yaml

echo "--- Con request_logging_enabled: true ---"
curl -s http://localhost:8000/greeting > /dev/null
curl -s http://localhost:8000/config > /dev/null
echo "Logs del contenedor (deberían mostrar las requests anteriores):"
docker compose logs api --tail 5

echo "--- Desactivando el logging por config ---"
sed -i 's/request_logging_enabled: true/request_logging_enabled: false/' "$CONFIG"
docker compose restart api
sleep 2

curl -s http://localhost:8000/greeting > /dev/null
curl -s http://localhost:8000/config > /dev/null
echo "Logs luego de desactivar (no deberían aparecer nuevas líneas de request):"
docker compose logs api --tail 5

echo "--- Restaurando config.yaml original ---"
sed -i 's/request_logging_enabled: false/request_logging_enabled: true/' "$CONFIG"
docker compose restart api
