#!/usr/bin/env bash
# Demo UT3: escalabilidad horizontal de catalog_service.
#
# La instancia original de catalog_service (docker-compose.yaml) sigue
# publicando el puerto 8002 y no se toca. Este script levanta 3 réplicas
# ADICIONALES, sin puerto fijo de host, como un proyecto de Compose
# separado (docker-compose.scaling.yml) sobre la misma red
# "investnow-net". Docker asigna a todas el mismo alias DNS
# "catalog_service" dentro de esa red, así que order_service (que ya
# corre en el stack principal) reparte sus consultas entre todas ellas
# por round-robin, sin agregar ningún balanceador nuevo a la arquitectura.
set -e

SCALING_PROJECT="investnow-scaling"
SCALING_COMPOSE="docker compose -p $SCALING_PROJECT -f docker-compose.scaling.yml"

echo "--- Levantando 3 réplicas adicionales de catalog_service (sin puerto de host) ---"
$SCALING_COMPOSE up -d --build --scale catalog_service=3
sleep 2

echo "--- Disparando 8 requests a GET /api/v1/assets a través de order_service ---"
for i in $(seq 1 8); do
  docker compose exec -T order_service python -c "
import httpx
r = httpx.get('http://catalog_service:8000/api/v1/assets', timeout=5.0)
print('served_by:', r.json()[0]['served_by'])
"
done
echo "Hostnames distintos entre requests == distintas réplicas (la original +"
echo "las 3 nuevas) atendiendo la misma solicitud sin coordinación entre sí."

echo "--- Bajando las réplicas adicionales (la instancia original sigue como estaba) ---"
$SCALING_COMPOSE down
