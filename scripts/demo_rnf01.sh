#!/usr/bin/env bash
# Demo RNF-01: binding en tiempo de configuración.
# Cambia business.mode en config.yaml, reinicia el contenedor y muestra que
# /greeting y /config reflejan el cambio sin tocar código.
set -e

CONFIG=app/config/config.yaml

echo "--- Estado inicial ---"
curl -s http://localhost:8000/config; echo
curl -s http://localhost:8000/greeting; echo

echo "--- Cambiando business.mode a 'formal' en config.yaml ---"
sed -i 's/mode: friendly/mode: formal/' "$CONFIG"

echo "--- Reiniciando el contenedor ---"
docker compose restart api
sleep 2

echo "--- Estado luego del cambio ---"
curl -s http://localhost:8000/config; echo
curl -s http://localhost:8000/greeting; echo

echo "--- Restaurando config.yaml original ---"
sed -i 's/mode: formal/mode: friendly/' "$CONFIG"
docker compose restart api
