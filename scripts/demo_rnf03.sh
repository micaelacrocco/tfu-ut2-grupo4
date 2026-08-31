#!/usr/bin/env bash
# Demo RNF-03: sanity checking antes de levantar el servidor.
# Con config inválida el contenedor no debe llegar a exponer el puerto.
set -e

CONFIG=app/config/config.yaml
INVALID=app/config/config.invalid.yaml
BACKUP=$(mktemp)

cp "$CONFIG" "$BACKUP"
trap 'cp "$BACKUP" "$CONFIG"; rm -f "$BACKUP"' EXIT

echo "--- Levantando con config inválida ---"
cp "$INVALID" "$CONFIG"
docker compose up -d --build
sleep 2

echo "Logs (deberían mostrar los errores de validación):"
docker compose logs api --tail 20
docker compose ps

echo "curl esperado a fallar (conexión rechazada):"
curl -s http://localhost:8000/config || echo "(falló como se esperaba, el servicio nunca se expuso)"

echo "--- Restaurando config válida y volviendo a levantar ---"
cp "$BACKUP" "$CONFIG"
docker compose up -d --build
sleep 2

echo "Ahora sí debería responder:"
curl -s http://localhost:8000/config; echo
