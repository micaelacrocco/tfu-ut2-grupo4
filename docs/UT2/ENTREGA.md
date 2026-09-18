# TFU UT2 — Tácticas de Arquitectura

> Documento de entrega de la **Unidad Temática 2**. Para el contexto de
> negocio y los requerimientos de UT1 ver
> [`../UT1/ENTREGA.md`](../UT1/ENTREGA.md); para la entrega de UT3 ver
> [`../UT3/ENTREGA.md`](../UT3/ENTREGA.md); para la visión general del
> proyecto y cómo levantar el stack completo, ver el
> [`README.md`](../../README.md) de la raíz.

Trabajo Final de la Unidad Temática 2 (Tácticas de Arquitectura). Este
documento contiene la Parte 2 del trabajo: una API REST mínima que
demuestra, en funcionamiento y desplegada en Docker, la combinación de
tácticas de arquitectura elegida en la Parte 1.

---

## 1. Contexto del problema

El objetivo es mostrar, mediante una demostración funcional, cómo la
combinación de distintas tácticas de arquitectura permite alcanzar
distintos atributos de calidad de manera simultánea. El equipo eligió la
siguiente combinación:

- **Una táctica de la categoría "detección de estados desprotegidos"** para
  el atributo de calidad **protección** → *sanity checking*.
- **Dos tácticas de la categoría "diferir el binding"** para el atributo de
  calidad **facilidad de modificación** → *binding en tiempo de
  configuración* y *aspectos*.

Un sistema más flexible en cuanto a su modificación, es decir, capaz de
cambiar su comportamiento sin modificar el código fuente, puede resultar
riesgoso si no valida su propia configuración antes de iniciar sus
servicios. Esta demostración integra ambos aspectos: la flexibilidad para
modificar el comportamiento mediante configuración, y una verificación que
impide que el sistema quede expuesto en un estado inválido.

La funcionalidad de negocio de la API no constituye el foco del trabajo: se trata de un endpoint de ejemplo, suficiente para disponer de un elemento sobre el cual observar los efectos
de las tácticas implementadas.

---

## 2. Requerimientos no funcionales (Parte 1)

A continuación se presentan los tres requerimientos no funcionales
definidos en la Parte 1 del trabajo.

### RNF-01 — Configuración externa

> El sistema deberá permitir habilitar, deshabilitar y ajustar
> funcionalidades y parámetros de negocio mediante un sistema de
> configuración externo, sin necesidad de modificar el código fuente ni
> recompilar la aplicación. Todo cambio de configuración deberá verse
> reflejado en menos de 60 segundos luego de reiniciar el sistema.

**Satisface a:** Binding en tiempo de configuración. La aplicación no
posee valores fijados en el código: toda la información se obtiene de un
archivo de configuración al momento de iniciar el proceso. Dado que la
decisión de habilitar o deshabilitar una funcionalidad se toma en ese
momento, y no en tiempo de desarrollo, resulta suficiente modificar el
archivo de configuración y reiniciar el sistema para modificar su
comportamiento, sin necesidad de modificar el código fuente.

### RNF-02 — Comportamientos transversales

> El sistema deberá permitir incorporar, modificar o eliminar
> comportamientos transversales, como el registro de logs o métricas, sin
> modificar la lógica principal de negocio. La activación o desactivación
> de estos comportamientos deberá realizarse únicamente mediante
> configuración y afectando a un único módulo aislado.

**Satisface a:** Aspectos. El comportamiento que se repite entre distintos
endpoints (como el registro de logs) se extrae de las funciones de negocio
y se concentra en un único módulo que las envuelve externamente. De esta
manera, las funciones de negocio permanecen enfocadas exclusivamente en su
propia responsabilidad. Dado que ese módulo se habilita o deshabilita
mediante configuración, el comportamiento transversal puede incorporarse o
retirarse modificando un único lugar.

### RNF-03 — Validación al inicio

> El sistema deberá validar la consistencia y validez de su configuración
> al iniciar y, en caso de detectar valores inválidos, incompletos o
> inconsistentes, deberá impedir su inicio y registrar de forma clara el
> motivo del error en menos de 3 segundos, sin llegar a exponer sus
> servicios.

**Satisface a:** Sanity checking. El sistema valida su propia
configuración inmediatamente después de iniciar, antes de comenzar a
atender solicitudes. Si detecta una inconsistencia, el proceso no continúa
y reporta el motivo del error, de manera que el sistema nunca llega a
operar en un estado desprotegido o inseguro.

---

## 3. Implementación de cada requerimiento (Parte 2)

### RNF-01 — Binding en tiempo de configuración

Toda la configuración reside en un único archivo externo,
`app/config/config.yaml`, que no forma parte del código fuente sino que se
lee como dato al iniciar el proceso. Contiene:

- Un **indicador de funcionalidad** (`greeting_enabled`) que habilita o
  deshabilita el endpoint de negocio de ejemplo.
- Un **indicador de aspecto** (`request_logging_enabled`), que controla la
  activación del comportamiento transversal descripto en el RNF-02.
- Parámetros de negocio ajustables (`greeting_message`, `mode`) que
  determinan la respuesta del endpoint de negocio.
- El puerto en el que escucha el servidor.

Al iniciar el proceso, el módulo de carga de configuración
(`app/config/loader.py`) lee dicho archivo una única vez y construye un
objeto de configuración en memoria, disponible para el resto de la
aplicación durante toda su ejecución. Ningún endpoint contiene valores de
negocio escritos en el código: estos siempre se obtienen a través de dicho
objeto.

**Momento en que ocurre el binding:** conviene distinguir tres instantes
posibles y precisar en cuál de ellos se resuelve la configuración.

- *Tiempo de build de la imagen* (`docker build`): el `Dockerfile` copia un
  `config.yaml` por defecto dentro de la imagen, pero ese valor nunca es el
  que efectivamente usa la aplicación al ejecutarse: `docker-compose.yaml`
  monta el directorio `app/config` del host como volumen, reemplazando el
  contenido empaquetado en la imagen. Es decir, el build de la imagen no
  fija ningún valor de negocio.
- *Tiempo de inicio del proceso* (arranque del contenedor / de
  `app/main.py`): este es el instante en el que ocurre el binding
  propiamente dicho. Al iniciarse, el proceso lee el archivo montado desde
  el host y construye el objeto de configuración; a partir de ahí, ese es
  el valor que queda ligado a la ejecución. Es lo que la táctica denomina
  "tiempo de configuración": posterior al build, pero anterior a que el
  sistema empiece a atender solicitudes.
- *Tiempo de ejecución continuo* (mientras el proceso ya está corriendo y
  atendiendo requests): en este instante el binding **no** cambia. El
  objeto de configuración queda fijo en memoria durante toda la vida del
  proceso; no hay recarga en caliente. Modificar `config.yaml` con el
  proceso corriendo no tiene ningún efecto hasta que el proceso (o el
  contenedor) se reinicia — lo cual es consistente con lo que pide el
  RNF-01 ("reflejado ... luego de reiniciar el sistema").

El endpoint de negocio de ejemplo, `GET /greeting`
(`app/routers/business.py`), constituye la demostración concreta del
requerimiento: si la funcionalidad se encuentra deshabilitada, responde con
código `404`; si está habilitada, construye el mensaje combinando el texto
configurado y el valor de `mode` (`friendly` o `formal`). De esta manera,
dos configuraciones distintas producen dos respuestas distintas sin que
medie ningún cambio de código.

Para poder evidenciar el estado anterior y posterior a un cambio sin
inspeccionar el archivo manualmente, `GET /config` (`app/routers/meta.py`)
devuelve la configuración activa tal como se encuentra cargada en el
proceso en ese momento.

**Flujo de la demostración:** se modifica `config.yaml`, se reinicia el
contenedor, y el cambio se refleja de inmediato en `/config` y en
`/greeting`, muy por debajo del límite de 60 segundos establecido por el
requerimiento, dada la baja complejidad de la aplicación.

### RNF-02 — Aspecto de logging

El comportamiento transversal (registrar cada solicitud: método, ruta,
código de estado y tiempo de respuesta) reside en un único módulo aislado,
`app/aspects/logging_aspect.py`. Dicho módulo se integra como middleware de
FastAPI, es decir, se ejecuta externamente a cada endpoint, envolviendo
todas las solicitudes entrantes sin que los endpoints de negocio tengan
conocimiento de su existencia.

La decisión de activar dicho middleware se concentra en `app/main.py`: al
construir la aplicación, se consulta el indicador
`request_logging_enabled` de la configuración, y únicamente si su valor es
`true` se registra el middleware. Si su valor es `false`, el middleware no
se registra: no se trata de una rama de código que no realiza ninguna
acción, sino que el aspecto no llega a incorporarse.

**Resultado:** los archivos de `app/routers/` no contienen ninguna línea
vinculada al registro de logs. Habilitar o deshabilitar este comportamiento
consiste en modificar una única línea de `config.yaml` y reiniciar el
sistema, sin necesidad de modificar los endpoints.

### RNF-03 — Sanity checking

Antes de construir la aplicación de FastAPI y antes de que Uvicorn proceda
a abrir el puerto, `app/main.py` ejecuta una validación sobre la
configuración cruda leída del archivo (`app/config/validator.py`). Dicha
validación revisa, entre otras cosas:

- Que el puerto sea un valor numérico.
- Que el `mode` de negocio sea uno de los valores permitidos
  (`friendly`/`formal`).
- Que los campos obligatorios (como el mensaje de saludo) estén presentes.

Si se detecta algún problema, el sistema informa cada error de forma
clara, indicando el campo involucrado y el motivo, y el proceso finaliza
con un código de salida distinto de cero: nunca se llega a instanciar el
servidor HTTP, por lo que el puerto no se abre en ningún momento. Si la
configuración es válida, el proceso continúa normalmente y el servidor se
inicia.

Un aspecto relevante de la implementación es que esta validación se
ejecuta en el momento en que se importa el módulo `app.main`, y no
únicamente cuando este se ejecuta de forma directa. Esta decisión es
deliberada: de este modo, la validación se aplica independientemente de si
el proceso se inicia mediante `python -m app.main` o mediante
`uvicorn app.main:app`, comando que importa el módulo internamente.

**Flujo de la demostración:** se reemplaza `config.yaml` por una variante
inválida (`app/config/config.invalid.yaml`, con un puerto no numérico, un
valor de `mode` fuera del rango permitido y un mensaje vacío), se intenta
iniciar el contenedor, y puede observarse en los registros que el proceso
finaliza reportando los tres errores detectados, sin que ninguna solicitud
`curl` logre establecer conexión. Al restaurar la configuración válida, el
contenedor se inicia nuevamente sin inconvenientes.

---

## 4. Estructura del proyecto

```
app/
  main.py           # orquesta: valida config -> arma la app -> levanta el servidor
  config/           # config.yaml de ejemplo + carga y validación de la configuración
  aspects/          # el aspecto de logging, aislado del resto de la app
  routers/          # endpoints: negocio (business.py) y meta (meta.py, GET /config)
docker/             # Dockerfile
docker-compose.yaml # levanta el servicio y monta app/config para editar sin rebuildear
scripts/            # arranque y demos de cada RNF
```

Cada responsabilidad se encuentra separada en su propio componente: la
carga de configuración, su validación, el aspecto transversal y los
endpoints de negocio no se mezclan entre sí.

---

## 5. Puesta en marcha del proyecto

### Con Docker (recomendado)

```bash
docker compose up --build
# o, equivalente:
bash scripts/start.sh
```

Esto construye la imagen, ejecuta la validación de configuración (sanity
check) e inicia la API en `http://localhost:8000`. El archivo
`app/config/config.yaml` queda montado como volumen, de modo que puede
modificarse desde el host y observar el efecto reiniciando el contenedor,
sin necesidad de reconstruir la imagen.

### Local, sin Docker (para desarrollo)

```bash
pip install -r requirements.txt
python -m app.main
```

### Endpoints disponibles

| Método | Path        | Descripción                                                        |
|--------|-------------|---------------------------------------------------------------------|
| GET    | `/config`   | Devuelve la configuración activa cargada en memoria (RNF-01).       |
| GET    | `/greeting` | Endpoint de negocio de ejemplo; su respuesta depende de la config.  |

```bash
curl http://localhost:8000/config
curl http://localhost:8000/greeting
```

---

## 6. Scripts

Todos los scripts asumen que se ejecutan desde la raíz del repositorio y
que Docker se encuentra en ejecución. `demo_rnf01.sh` y `demo_rnf02.sh`
requieren que el stack ya se encuentre iniciado (`bash scripts/start.sh` o
`docker compose up -d` en otra terminal); `demo_rnf03.sh` gestiona su
propio ciclo de `docker compose up`, por lo que no requiere una
inicialización previa.

| Script                   | Qué hace |
|---------------------------|----------|
| `scripts/start.sh`        | Inicia el stack (`docker compose up --build`). |
| `scripts/demo_rnf01.sh`   | Consulta `/config` y `/greeting`, modifica `mode` en `config.yaml`, reinicia el contenedor y vuelve a consultar ambos endpoints para evidenciar el cambio reflejado sin modificar el código. Al finalizar, restaura `config.yaml`. |
| `scripts/demo_rnf02.sh`   | Envía solicitudes con `request_logging_enabled: true` y muestra los registros generados; luego deshabilita el indicador por configuración, reinicia el contenedor, repite las solicitudes y evidencia que no se genera ningún registro nuevo. Al finalizar, restaura `config.yaml`. |
| `scripts/demo_rnf03.sh`   | Reemplaza `config.yaml` por una variante inválida, inicia el contenedor y evidencia que el proceso falla reportando los errores de validación y que el puerto no responde; luego restaura la configuración válida y evidencia que el sistema se inicia correctamente. |

```bash
bash scripts/demo_rnf01.sh
bash scripts/demo_rnf02.sh
bash scripts/demo_rnf03.sh
```

---

## 7. Trazabilidad rápida

| RNF    | Táctica                      | Mecanismo clave                                   | Script            |
|--------|-------------------------------|----------------------------------------------------|-------------------|
| RNF-01 | Binding en tiempo de config.  | `config.yaml` + `GET /config` + `GET /greeting`     | `demo_rnf01.sh`   |
| RNF-02 | Aspectos                      | Middleware de logging aislado en `aspects/`         | `demo_rnf02.sh`   |
| RNF-03 | Sanity checking                | Validación pre-arranque en `main.py`                | `demo_rnf03.sh`   |

---

## 8. Fuera de alcance (a propósito)

Este proyecto es intencionalmente mínimo. Quedan fuera de alcance: base de
datos y persistencia real, autenticación/autorización, lógica de negocio
compleja, tests automatizados exhaustivos, y hot-reload de configuración en
caliente (el RNF-01 pide reiniciar el sistema, no un reload sin downtime).
