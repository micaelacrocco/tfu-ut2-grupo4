
# Documento de Alcance y Definición Arquitectónica: Demostración Unidad 3 (*InvestNow*)

> Documento de entrega de la **Unidad Temática 3**, incremental sobre
> [`../UT2/ENTREGA.md`](../UT2/ENTREGA.md) (y sobre el contexto de
> negocio y requerimientos de [`../UT1/ENTREGA.md`](../UT1/ENTREGA.md)).
> Para los comandos `curl` de
> verificación de cada interfaz ver
> [`PRUEBAS_ENDPOINTS.md`](PRUEBAS_ENDPOINTS.md); para la visión general
> del proyecto y cómo levantar el stack completo, ver el
> [`README.md`](../../README.md) de la raíz.

## 1. Introducción y Ajuste de Alcance para la Demo

El alcance del dominio fintech *InvestNow* consta de una API REST funcional que interconecta tres microservicios esenciales. Se descartan temporalmente las integraciones externas complejas en tiempo real (como pasarelas bancarias o brokers reales) simulándolas mediante contratos internos o mocks estables, garantizando que el sistema sea completamente testeable mediante `curl` o Postman y desplegable mediante contenedores.

---

## 2. Definición de Componentes, Interfaces y Dependencias

La solución se descompone en tres componentes principales desacoplados:

1. **Servicio de Catálogo y Activos**
* **Responsabilidad:** Administra el listado de activos financieros disponibles para operar (acciones, ETFs, criptomonedas) y su estado de habilitación.
* **Interfaces Expuestas:**
* `GET /api/v1/assets` (Pública, REST/JSON): Permite consultar el catálogo de activos.
* `PATCH /api/v1/assets/{id}/status` (Administración, REST/JSON): Modifica el estado de habilitación de un activo.


* **Interfaces Consumidas:** Ninguna.
* **Dependencias:** Ninguna (actúa como proveedor de datos primarios de catálogo).


2. **Servicio de Cuentas y Saldos (Wallet)**
* **Responsabilidad:** Administra el balance de los usuarios y aplica operaciones financieras atómicas.
* **Interfaces Expuestas:**
* `GET /api/v1/wallets/{user_id}` (Pública, REST/JSON): Consulta el saldo y portafolio del usuario.
* `POST /api/v1/wallets/transact` (Interna, REST): Interfaz de servicio a servicio para debitar o acreditar fondos de manera estricta.


* **Interfaces Consumidas:** Ninguna.
* **Dependencias:** Base de datos relacional transaccional (motor ACID).


3. **Servicio de Órdenes (Core de Negocio)**
* **Responsabilidad:** Procesa las solicitudes de compra y venta de activos por parte de los usuarios, aplicando validaciones de negocio.
* **Interfaces Expuestas:**
* `POST /api/v1/orders` (Pública, REST/JSON): Recibe la intención de compra o venta de un activo.
* `GET /api/v1/orders/{user_id}` (Pública, REST/JSON): Consulta el historial de órdenes del usuario.


* **Interfaces Consumidas:**
* Consume la interfaz de consulta del *Servicio de Catálogo* para verificar si el activo está habilitado antes de procesar la orden.
* Consume la interfaz interna del *Servicio de Cuentas y Saldos* para bloquear o debitar el dinero de forma sincronizada.


* **Dependencias:** *Servicio de Catálogo* y *Servicio de Cuentas y Saldos*.



---

## 3. Justificación de la Partición de Primer Nivel

* **Criterio de partición:** Partición basada en **Dominios de Negocio (*Bounded Contexts*)**.
* **Justificación:** Se separa el dominio de **Catálogo** (foco en lectura y disponibilidad) del dominio **Transaccional/Órdenes y Saldos** (foco en consistencia estricta de datos financieros). Esta partición de primer nivel permite escalar de forma independiente las consultas de activos sin comprometer los límites de consistencia y seguridad requeridos para las operaciones monetarias de los usuarios.

---

## 4. Proceso para el Descubrimiento de Componentes

El proceso metodológico aplicado para llegar a esta estructura de componentes consistió en:

1. **Derivación de Casos de Uso:** Análisis de las interacciones principales del inversor (consultar activos, ver saldo, enviar órdenes de compra/venta).
2. **Análisis de Cohesión y Acoplamiento Funcional:** Agrupación de datos y comportamientos afines. Se detectó que la gestión de activos respondía a ciclos de vida administrativos distintos a la gestión de saldos monetarios o a la ejecución de intenciones de mercado, separándolos lógicamente.
3. **Mapeo de Contratos de Interfaz:** Definición estricta de los puntos de contacto (REST para clientes y para la comunicación sincrónica entre el servicio de órdenes y los servicios de catálogo/saldos), asegurando un acoplamiento débil y contratos bien tipados.

---

## 5. Análisis de Impacto de Infraestructura: Contenedores vs. Máquinas Virtuales

* **Opción elegida para la solución:** Contenedores (orquestados mediante `docker-compose`).
* **Análisis de impacto de la opción no elegida (Máquinas Virtuales):**
* *Despliegue y Empaquetado:* En lugar de empaquetar cada microservicio en una imagen ligera de Docker con su runtime aislado, se requeriría aprovisionar una máquina virtual completa por cada componente (o un monolito virtualizado). Esto elevaría la complejidad de configuración del sistema operativo invitado en cada nodo.
* *Consumo de Recursos y Densidad:* Las VMs duplicarían la sobrecarga de memoria RAM y CPU al arrancar un kernel de sistema operativo por separado para cada servicio, reduciendo la densidad de despliegue en entornos de desarrollo o pruebas.
* *Velocidad de Provisionamiento:* Los tiempos de inicio y pruebas dinámicas pasarían de segundos (contenedores) a minutos (aprovisionamiento de VMs), dificultando la agilidad en los scripts de demostración automatizada.



---

## 6. Análisis de Impacto de Modelos de Consistencia: ACID vs. BASE

* **Opción elegida para la solución:** Modelo **ACID con transacciones** (aplicado en el subsistema de saldos y órdenes).
* **Análisis de impacto de la opción no elegida (BASE - Consistencia Eventual):**
* *Pérdida de Atomicidad Financiera:* Si se adoptara un modelo BASE (priorizando disponibilidad y particionamiento mediante consistencia eventual), un usuario podría emitir una orden de compra y ver su saldo actualizado de manera diferida.
* *Riesgo de Negocio:* Esto permitiría condiciones de carrera (*race conditions*) donde un inversor podría gastar fondos inexistentes o duplicados antes de que la red propague el estado real del saldo a los demás microservicios.
* *Conclusión:* Para un dominio financiero, el sacrificio de consistencia que impone BASE resulta inaceptable, obligando a asumir el costo de bloqueo y sincronización estricta que provee ACID.

El diagrama se puede ver y editar en https://editor.plantuml.com

@startuml
skinparam defaultTextAlignment center
skinparam componentStyle uml2

title Diagrama de Componentes UML - InvestNow (Interfaces y Dependencias)

' Definición de los componentes principales
component "[ Servicio de Catálogo ]" as CatalogService
component "[ Servicio de Cuentas y Saldos ]" as WalletService
component "[ Servicio de Órdenes ]" as OrderService

' -------------------------------------------------------------
' 1. INTERFACES EXPUESTAS (Proporcionadas / "Lollipop")
' -------------------------------------------------------------
interface "I-CAT-01: Consulta de Activos\n(GET /api/v1/assets)" as ICatPublic
interface "I-CAT-02: Administración\n(PATCH /assets/{id}/status)" as ICatAdmin
interface "I-WAL-01: Consulta de Saldo\n(GET /api/v1/wallets/{id})" as IWalPublic
interface "I-WAL-02: Transacción Atómica ACID\n(POST /wallets/transact)" as IWalInternal
interface "I-ORD-01: Gestión de Órdenes\n(POST/GET /api/v1/orders)" as IOrdPublic

' Conexión de los componentes con las interfaces que EXPONEN
CatalogService -- ICatPublic
CatalogService -- ICatAdmin
WalletService -- IWalPublic
WalletService -- IWalInternal
OrderService -- IOrdPublic

' -------------------------------------------------------------
' 2. INTERFACES CONSUMIDAS Y DEPENDENCIAS (Requeridas / "Socket")
' -------------------------------------------------------------
' El Servicio de Órdenes requiere (consume) las interfaces de Catálogo y Cuentas
OrderService ..> ICatPublic : "Consume"
OrderService ..> IWalInternal : "Consume"

@enduml

