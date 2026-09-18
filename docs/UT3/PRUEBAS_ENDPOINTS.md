# Guía de Pruebas de Endpoints - InvestNow (Unidad 3)

> Complementa [`ENTREGA.md`](ENTREGA.md) (Unidad 3).

Documentación de referencia rápida con comandos `curl` para verificar el funcionamiento de las interfaces expuestas por cada microservicio de la plataforma desplegado en Docker.

Antes de correr estos comandos: `cp .env.example .env` y `docker compose up --build` desde la raíz del repo. Para los scripts que demuestran ACID, statelessness y escalabilidad horizontal ver la sección 7 de [`ENTREGA.md`](ENTREGA.md).

---

## 1. Servicio de Catálogo de Activos (`http://localhost:8002`)

### Consultar Catálogo de Activos (`I-CAT-01`)

Permite obtener el listado completo de activos financieros disponibles en la plataforma.

```bash
curl -X GET http://localhost:8002/api/v1/assets \
  -H "Content-Type: application/json"

```

Cada activo devuelto incluye `served_by` (hostname del contenedor que respondió), usado en `scripts/demo_ut3_scaling.sh` para evidenciar que distintas réplicas atienden la misma consulta.

### Actualizar Estado de un Activo (`I-CAT-02`)

Interfaz administrativa para habilitar o deshabilitar la operación de un activo específico.

```bash
curl -X PATCH "http://localhost:8002/api/v1/assets/1/status?status=inactive" \
  -H "Content-Type: application/json"

```

*(Para volver a activarlo: `status=active`)*

---

## 2. Servicio de Cuentas y Saldos / Wallet (`http://localhost:8001`)

### Consultar Saldo de Usuario (`I-WAL-01`)

Permite verificar el balance actual de la cuenta de un inversor.

```bash
curl -X GET http://localhost:8001/api/v1/wallets/1 \
  -H "Content-Type: application/json"

```

### Ejecutar Transacción Atómica ACID (`I-WAL-02`)

Aplica un débito o crédito estricto sobre el saldo del usuario, aplicando validación estricta contra fondos insuficientes.

```bash
curl -X POST http://localhost:8001/api/v1/wallets/transact \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "amount": -150.0
  }'

```

*(Nota: un monto negativo representa un débito o compra; si supera el saldo disponible, la transacción es abortada).*

---

## 3. Servicio de Órdenes / Core de Negocio (`http://localhost:8003`)

### Registrar y Procesar Orden de Compra (`I-ORD-01`)

Esta interfaz demuestra la **dependencia y consumo cruzado** entre microservicios: al recibir la orden, el servicio verifica en tiempo real la disponibilidad del activo en el *Servicio de Catálogo* y efectúa el bloqueo de fondos llamando al *Servicio de Wallet*.

```bash
curl -X POST http://localhost:8003/api/v1/orders \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "asset_id": 1,
    "quantity": 2,
    "total_price": 150.0
  }'

```

### Consultar Historial de Órdenes por Usuario (`I-ORD-01`)

Permite recuperar todas las operaciones procesadas para un inversor determinado.

```bash
curl -X GET http://localhost:8003/api/v1/orders/1 \
  -H "Content-Type: application/json"

```