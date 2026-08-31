# Guion — Presentación TFU UT2

Guía rápida para presentar `presentacion.html` (10 diapositivas, se navega
con las flechas o el mouse). Pensado para que cualquiera del equipo lo
pueda leer una vez y presentar sin memorizar nada palabra por palabra —
son ideas, no un texto para recitar. Tiempo total sugerido: **~5 minutos**
(el límite que pide la consigna).

Idea general para tener siempre presente: **elegimos volver el sistema
más fácil de modificar (sin tocar código) y, al mismo tiempo, más seguro
(no arranca si algo está mal configurado)**. Todo lo demás son detalles de
cómo se logra eso.

---

### 1. Portada — 15 seg

Decir quiénes son y qué van a mostrar: una API chica en FastAPI donde se
ven funcionando, en vivo, tres tácticas de arquitectura combinadas.

---

### 2. El problema — 30 seg

Explicar que la consigna pedía combinar tácticas de dos categorías
distintas para lograr dos atributos de calidad a la vez, y que el equipo
eligió: **protección** (con *sanity checking*) + **facilidad de
modificación** (con *binding en tiempo de configuración* y *aspectos*).

**Frase fácil:** "Queríamos un sistema flexible, que se pueda cambiar sin
tocar código — pero que esa misma flexibilidad no lo vuelva inseguro."

---

### 3. RNF-01 — Configuración externa — 30 seg

Leer o parafrasear el requerimiento (está completo en la diapositiva). Lo
importante para remarcar: nada de negocio está escrito fijo en el código,
todo sale de un archivo de configuración.

**Frase fácil:** "Es como los ajustes de una app: para cambiar el modo
oscuro no hace falta reinstalarla, solo tocás un botón. Acá es lo mismo,
pero con un archivo."

---

### 4. RNF-02 — Comportamientos transversales — 30 seg

Mismo criterio: leer el requerimiento y remarcar que habla de un
comportamiento que se repite en todos lados (como el logging) y que tiene
que poder prenderse o apagarse sin tocar la lógica de negocio.

**Frase fácil:** "Es el mismo principio que el access log de Nginx o de un
API Gateway: ese registro no vive adentro del código de cada endpoint,
vive en una capa aparte que envuelve todo el tráfico. Acá hicimos lo mismo
pero a nivel de la aplicación: un único middleware de FastAPI envuelve
todos los endpoints, y se prende o apaga sin tocar ninguno de ellos."

---

### 5. RNF-03 — Validación al inicio — 30 seg

Leer el requerimiento. Remarcar el punto clave: si algo está mal, el
sistema **ni siquiera llega a exponer el servicio**.

**Frase fácil:** "Es como el control antes de que despegue un avión: si
algo no cierra, el avión no arranca a rodar. Acá, si la config no cierra,
el servidor no abre el puerto."

---

### 6. Arquitectura — ¿Cómo arranca el sistema? — 40 seg

Acá se muestra el diagrama. Seguirlo de izquierda a derecha:

1. Se lee `config.yaml`.
2. Se arma el objeto de configuración.
3. Se valida.
4. Si **no** es válida → corta ahí mismo, nunca llega a abrir el puerto
   (señalar la caja de arriba, la del `sys.exit(1)`).
5. Si es válida → sigue, arma la aplicación y recién ahí expone el
   puerto (señalar el nodo verde de la derecha).

**Frase fácil:** "El puerto de la derecha solo existe si se pasa por el
camino de abajo. Si algo falla en la validación, ese nodo verde
literalmente nunca se dibuja."

---

### 7. Arquitectura — ¿Cómo se atiende un request? — 40 seg

Mostrar el diagrama de la izquierda y acompañar con los puntos de la
derecha. La idea central: el logging **envuelve** a los endpoints desde
afuera, no vive adentro de ellos.

**Frase fácil:** "Es una caja que se pone alrededor de los endpoints, no
adentro. Si se apaga el flag, la caja directamente desaparece — ni el
cliente ni el endpoint notan la diferencia."

Aprovechar para señalar que `AppConfig` (la configuración cargada) está
afuera de esa caja: la usan los endpoints, pero no es parte del aspecto.

---

### 8. De la táctica a la implementación — 35 seg

Recorrer las tres columnas rápido, una frase por columna, conectando cada
táctica con dónde vive en el código:

- **RNF-01:** todo sale de `config.yaml`; `/config` y `/greeting` lo
  demuestran en vivo.
- **RNF-02:** el logging está aislado en un único archivo, y se prende o
  apaga por config.
- **RNF-03:** la validación corre antes de crear la app; si falla, el
  proceso corta con un error claro.

---

### 9. Demo — 25 seg

Mostrar los 4 scripts y explicar en una frase qué hace cada uno (están
resumidos en las tarjetas). No hace falta correrlos todos en vivo si el
tiempo aprieta — con mostrar uno (por ejemplo `demo_rnf03.sh`, que es el
más visual: falla y no abre el puerto) alcanza para que se entienda la
lógica de los otros.

---

### 10. Cierre — 15 seg

Repasar la tabla de trazabilidad en una frase ("cada RNF tiene su táctica,
su mecanismo y su script de demo") y cerrar agradeciendo.

---

## Tip general

Si hay que recortar tiempo, lo primero que se puede achicar es la
diapositiva 8 (es un repaso de algo que ya se explicó en las diapositivas
3 a 7). Lo que **no** conviene saltear son las diapositivas 6 y 7 — son
las que muestran, con evidencia visual, que las tácticas están realmente
implementadas y no son solo una promesa en un documento.
