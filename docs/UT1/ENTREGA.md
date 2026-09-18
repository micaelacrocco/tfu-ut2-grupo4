# TFU UT1 — Contexto de negocio y Requerimientos (InvestNow)

> Documento de entrega de la **Unidad Temática 1**. Es la base sobre la
> que se apoyan las decisiones arquitectónicas de
> [`../UT2/ENTREGA.md`](../UT2/ENTREGA.md) y
> [`../UT3/ENTREGA.md`](../UT3/ENTREGA.md); para la visión general del
> proyecto ver el [`README.md`](../../README.md) de la raíz.

---

## Parte 1 – Contexto del negocio e Historias de Usuario

### Contexto del negocio

InvestNow es una fintech que ofrece una plataforma digital de inversión
dirigida a pequeños y medianos inversores particulares que hoy no acceden
a productos de trading tradicionales por barreras de costo, complejidad o
mínimos de inversión elevados. La plataforma permite a los usuarios abrir
una cuenta de inversión 100% digital, depositar fondos, comprar y vender
activos financieros (acciones, ETFs y criptomonedas) en tiempo real, y
hacer seguimiento de su portafolio.

El objetivo del desarrollo es democratizar el acceso a los mercados
financieros ofreciendo una experiencia simple, rápida y confiable,
compitiendo con brokers tradicionales mediante menores comisiones y una
interfaz orientada a usuarios sin experiencia previa en finanzas. Al
operar con dinero real y datos de mercado en vivo, el negocio depende
críticamente de que la plataforma esté siempre disponible durante el
horario de mercado, ejecute órdenes con baja latencia, proteja los fondos
y datos personales de los usuarios, y pueda evolucionar rápido para
incorporar nuevos activos y cumplir regulaciones cambiantes sin
interrumpir el servicio.

### Historias de usuario

- **HU-01 – Registro y verificación de identidad.** Como usuario nuevo,
  quiero crear una cuenta y verificar mi identidad con documento y foto,
  para poder operar legalmente en la plataforma.
- **HU-02 – Depósito de fondos.** Como usuario registrado, quiero
  depositar dinero en mi cuenta desde mi banco, para tener saldo
  disponible para invertir.
- **HU-03 – Consulta de cotizaciones en tiempo real.** Como usuario,
  quiero ver el precio actualizado de los activos que me interesan, para
  decidir cuándo comprar o vender.
- **HU-04 – Compra/venta de activos (ejecución de órdenes).** Como
  usuario, quiero enviar una orden de compra o venta de un activo, para
  que se ejecute al mejor precio disponible en el momento.
- **HU-05 – Consulta de portafolio y movimientos.** Como usuario, quiero
  ver el estado actual de mi portafolio y el historial de mis
  operaciones, para hacer seguimiento de mis inversiones.
- **HU-06 – Retiro de fondos.** Como usuario, quiero retirar dinero de mi
  cuenta hacia mi banco, para disponer de mis ganancias o fondos no
  invertidos.
- **HU-07 – Administración de catálogo de activos (rol interno).** Como
  administrador de la plataforma, quiero habilitar o deshabilitar activos
  disponibles para operar, para adaptar la oferta a nuevas regulaciones o
  acuerdos con mercados.

---

## Parte 2 – Requerimientos arquitectónicamente significativos

A partir de las historias de usuario que obtuvimos al principio,
identificamos varios requerimientos que tienen un impacto importante
sobre la arquitectura de InvestNow. Estos requerimientos surgen
principalmente de la integración con sistemas externos, el manejo de
dinero e información sensible, la necesidad de procesar órdenes
rápidamente y la posibilidad de modificar y desplegar la plataforma sin
interrumpir el servicio.

Además de los requerimientos que obtuvimos directamente de las historias
de usuario, se incorporan requerimientos no funcionales relacionados con
disponibilidad, rendimiento, protección, seguridad, facilidad de
modificación y facilidad de despliegue.

> **Nota:** utilizamos la plantilla de requerimientos vista en ANDIS 1
> para seguir un cierto estándar entre los requerimientos.

### Requerimientos funcionales significativos (ASR)

#### ASR-01: Integración con el proveedor de identidad

- **Evento/Caso de uso:** HU-01, Registro y verificación de identidad.
- **Descripción:** El sistema deberá enviar los datos y documentos de
  identidad del usuario a un proveedor externo de validación y registrar
  el resultado de la verificación.
- **Justificación:** InvestNow necesita verificar la identidad de cada
  usuario antes de permitirle operar, tanto por motivos legales como para
  reducir el riesgo de fraude.
- **Criterio de ajuste:** En una prueba realizada con el ambiente de
  integración del proveedor, el sistema deberá enviar correctamente los
  datos requeridos, recibir el resultado de la validación y registrar si
  la identidad fue aprobada, rechazada o quedó pendiente. Un usuario cuya
  identidad no haya sido aprobada no deberá poder depositar fondos ni
  registrar órdenes.
- **Satisfacción / Insatisfacción del cliente:** 5 / 5.
- **Prioridad:** Must have.
- **Dependencias:** RNF-07 y RNF-08.
- **Conflictos:** No se identifican conflictos directos.
- **Material de soporte:** HU-01 y documentación del proveedor de
  validación de identidad.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

#### ASR-02: Integración con proveedores bancarios

- **Evento/Caso de uso:** HU-02, Depósito de fondos; HU-06, Retiro de
  fondos.
- **Descripción:** El sistema deberá integrarse con proveedores bancarios
  para recibir depósitos, solicitar retiros y actualizar el estado de
  cada transferencia.
- **Justificación:** Los usuarios necesitan transferir dinero entre su
  cuenta bancaria y su cuenta de InvestNow para poder invertir y retirar
  sus fondos.
- **Criterio de ajuste:** En una prueba realizada con el ambiente de
  integración bancaria, el sistema deberá registrar correctamente las
  transferencias aceptadas, rechazadas y pendientes. Una transferencia
  rechazada no deberá modificar el saldo disponible del usuario.
- **Satisfacción / Insatisfacción del cliente:** 5 / 5.
- **Prioridad:** Must have.
- **Dependencias:** RNF-05, RNF-06 y RNF-07.
- **Conflictos:** No se identifican conflictos directos.
- **Material de soporte:** HU-02, HU-06 y documentación de los
  proveedores bancarios.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

#### ASR-03: Distribución de cotizaciones

- **Evento/Caso de uso:** HU-03, Consulta de cotizaciones en tiempo real.
- **Descripción:** El sistema deberá obtener las cotizaciones desde un
  proveedor externo y distribuir cada actualización a los usuarios
  interesados en el activo correspondiente.
- **Justificación:** Consultar al proveedor por cada usuario conectado
  generaría una cantidad innecesaria de solicitudes, aumentaría los
  costos y limitaría la cantidad de usuarios que la plataforma puede
  atender.
- **Criterio de ajuste:** En una prueba con varios usuarios observando el
  mismo activo, el sistema deberá obtener una única actualización desde
  el proveedor y distribuirla a todos los usuarios suscritos a ese
  activo.
- **Satisfacción / Insatisfacción del cliente:** 5 / 4.
- **Prioridad:** Must have.
- **Dependencias:** RNF-01, RNF-03 y RNF-04.
- **Conflictos:** No se identifican conflictos directos.
- **Material de soporte:** HU-03 y documentación del proveedor de
  cotizaciones.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

#### ASR-04: Envío de órdenes al intermediario financiero

- **Evento/Caso de uso:** HU-04, Compra y venta de activos.
- **Descripción:** El sistema deberá enviar las órdenes de compra y venta
  a un mercado o intermediario financiero externo y registrar el
  resultado informado por este.
- **Justificación:** InvestNow no ejecuta las operaciones directamente,
  por lo que necesita integrarse con un tercero que tenga acceso al
  mercado.
- **Criterio de ajuste:** Para cada orden aceptada por InvestNow, el
  sistema deberá enviarla al intermediario financiero y registrar su
  identificador externo y su estado. Los estados posibles deberán
  incluir, como mínimo, pendiente, aceptada, ejecutada, rechazada y
  cancelada.
- **Satisfacción / Insatisfacción del cliente:** 5 / 5.
- **Prioridad:** Must have.
- **Dependencias:** ASR-05, RNF-03, RNF-05 y RNF-06.
- **Conflictos:** No se identifican conflictos directos.
- **Material de soporte:** HU-04 y documentación del intermediario
  financiero.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

#### ASR-05: Prevención de órdenes duplicadas

- **Evento/Caso de uso:** HU-04, Compra y venta de activos.
- **Descripción:** El sistema deberá evitar que una misma orden sea
  registrada o enviada al intermediario financiero más de una vez ante
  reintentos o fallas de comunicación.
- **Justificación:** La ejecución duplicada de una orden puede producir
  compras o ventas no solicitadas y generar pérdidas económicas para el
  usuario.
- **Criterio de ajuste:** Al enviar varias veces una solicitud con el
  mismo identificador, el sistema deberá registrar y enviar una sola
  orden al intermediario. Todos los reintentos deberán devolver el
  resultado correspondiente a la orden original.
- **Satisfacción / Insatisfacción del cliente:** 5 / 5.
- **Prioridad:** Must have.
- **Dependencias:** ASR-04, RNF-05 y RNF-06.
- **Conflictos:** No se identifican conflictos directos.
- **Material de soporte:** HU-04 y ASR-04.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

#### ASR-06: Propagación de la deshabilitación de activos

- **Evento/Caso de uso:** HU-07, Administración del catálogo de activos.
- **Descripción:** El sistema deberá propagar la deshabilitación de un
  activo a todos los componentes encargados de consultar cotizaciones y
  registrar órdenes.
- **Justificación:** Cuando un activo deja de estar disponible por una
  decisión comercial o regulatoria, la plataforma debe impedir que se
  registren nuevas órdenes sobre ese activo.
- **Criterio de ajuste:** Luego de que un administrador deshabilite un
  activo, ningún componente de la plataforma deberá aceptar nuevas
  órdenes sobre ese activo después de transcurridos cinco segundos. Las
  órdenes registradas anteriormente deberán conservar su estado y
  trazabilidad.
- **Satisfacción / Insatisfacción del cliente:** 4 / 5.
- **Prioridad:** Must have.
- **Dependencias:** RNF-09 y RNF-10.
- **Conflictos:** No se identifican conflictos directos.
- **Material de soporte:** HU-07.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

Nota: los identificadores `ASR-0N` de esta sección corresponden a los
requerimientos funcionales arquitectónicamente significativos de UT1 y no
deben confundirse con los `RNF-0N` de UT2 (Parte 1, tácticas de
arquitectura), que son un subconjunto distinto elegido para esa entrega
puntual.

### Requerimientos no funcionales

#### Disponibilidad

**RNF-01: Disponibilidad durante el horario de mercado**

- **Evento/Caso de uso:** HU-03, Consulta de cotizaciones en tiempo real;
  HU-04, Compra y venta de activos.
- **Descripción:** El sistema deberá mantener disponibles la consulta de
  cotizaciones y el registro de órdenes durante las horas de actividad
  del mercado financiero.
- **Justificación:** Los usuarios necesitan consultar precios y registrar
  órdenes mientras el mercado se encuentra activo. Una interrupción
  durante ese período puede provocar la pérdida de oportunidades de
  inversión.
- **Criterio de ajuste:** Al finalizar cada mes, los registros de
  monitoreo deberán demostrar una disponibilidad mínima de 99,9% para la
  consulta de cotizaciones y el registro de órdenes durante el horario de
  actividad del mercado. No se incluirán las ventanas de mantenimiento
  comunicadas previamente.
- **Satisfacción / Insatisfacción del cliente:** 5 / 5.
- **Prioridad:** Must have.
- **Dependencias:** RNF-02 y RNF-11.
- **Conflictos:** No se identifican conflictos directos.
- **Material de soporte:** Contexto de negocio, HU-03 y HU-04.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

**RNF-02: Recuperación ante la caída de la infraestructura principal**

- **Evento/Caso de uso:** HU-02, Depósito de fondos; HU-04, Compra y
  venta de activos; HU-06, Retiro de fondos.
- **Descripción:** El sistema deberá restablecer el registro de
  operaciones mediante una infraestructura de respaldo ante la caída de
  la infraestructura principal.
- **Justificación:** InvestNow opera con dinero real y no puede quedar
  fuera de servicio durante períodos prolongados por una falla de
  infraestructura.
- **Criterio de ajuste:** En una prueba controlada de caída total de la
  infraestructura principal, el sistema deberá restablecer el registro de
  operaciones en menos de 30 segundos y no deberá perder ninguna
  operación confirmada previamente al usuario.
- **Satisfacción / Insatisfacción del cliente:** 5 / 5.
- **Prioridad:** Must have.
- **Dependencias:** RNF-05 y RNF-11.
- **Conflictos:** No se identifican conflictos directos.
- **Material de soporte:** Contexto de negocio, HU-02, HU-04 y HU-06.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

#### Rendimiento

**RNF-03: Tiempo de respuesta del registro de órdenes**

- **Evento/Caso de uso:** HU-04, Compra y venta de activos.
- **Descripción:** El sistema deberá registrar las órdenes de compra y
  venta con un tiempo de respuesta adecuado para la operación en mercados
  financieros.
- **Justificación:** El precio de los activos puede cambiar rápidamente.
  Una demora en el registro de una orden puede hacer que el usuario opere
  en condiciones diferentes a las esperadas.
- **Criterio de ajuste:** En condiciones normales de operación, el 95% de
  las solicitudes de registro de órdenes deberá recibir una respuesta en
  menos de 500 milisegundos, medidos desde que el sistema recibe la
  solicitud hasta que confirma su registro.
- **Satisfacción / Insatisfacción del cliente:** 5 / 5.
- **Prioridad:** Must have.
- **Dependencias:** RNF-04, RNF-05 y RNF-06.
- **Conflictos:** El registro de auditoría definido en RNF-06 puede
  agregar tiempo de procesamiento, por lo que ambos requerimientos
  deberán considerarse en conjunto.
- **Material de soporte:** Contexto de negocio y HU-04.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

**RNF-04: Capacidad de procesamiento de órdenes**

- **Evento/Caso de uso:** HU-04, Compra y venta de activos.
- **Descripción:** El sistema deberá soportar el procesamiento
  concurrente de órdenes durante períodos de alta demanda.
- **Justificación:** Los eventos financieros pueden generar aumentos
  repentinos en la cantidad de usuarios que intentan operar al mismo
  tiempo.
- **Criterio de ajuste:** En una prueba de carga de al menos diez
  minutos, el sistema deberá procesar 5000 solicitudes de registro de
  órdenes por segundo y mantener una tasa de errores inferior al 1%.
- **Satisfacción / Insatisfacción del cliente:** 5 / 5.
- **Prioridad:** Must have.
- **Dependencias:** RNF-02 y RNF-03.
- **Conflictos:** No se identifican conflictos directos.
- **Material de soporte:** Contexto de negocio y HU-04.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

#### Protección

**RNF-05: Integridad de las operaciones de saldo**

- **Evento/Caso de uso:** HU-02, Depósito de fondos; HU-04, Compra y
  venta de activos; HU-06, Retiro de fondos.
- **Descripción:** El sistema deberá ejecutar de forma atómica todas las
  operaciones que modifiquen el saldo o el portafolio de un usuario.
- **Justificación:** Una interrupción durante el procesamiento no puede
  dejar un débito, un crédito o un movimiento parcialmente aplicado.
- **Criterio de ajuste:** Al interrumpir intencionalmente una operación
  en cualquier etapa de su procesamiento, la operación deberá completarse
  en su totalidad o revertirse sin modificar el saldo ni el portafolio
  del usuario. En las pruebas realizadas no deberá encontrarse ninguna
  modificación parcial.
- **Satisfacción / Insatisfacción del cliente:** 5 / 5.
- **Prioridad:** Must have.
- **Dependencias:** RNF-06.
- **Conflictos:** Los controles de integridad pueden afectar los tiempos
  definidos en RNF-03 y RNF-04, por lo que deberán considerarse en
  conjunto.
- **Material de soporte:** HU-02, HU-04, HU-06 y ASR-03.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

**RNF-06: Registro de auditoría de operaciones**

- **Evento/Caso de uso:** HU-02, Depósito de fondos; HU-04, Compra y
  venta de activos; HU-06, Retiro de fondos.
- **Descripción:** El sistema deberá generar un registro de auditoría
  inmutable para todas las operaciones que modifiquen fondos, saldos o
  activos de los usuarios.
- **Justificación:** InvestNow necesita reconstruir el historial de las
  operaciones, investigar incidentes, resolver reclamos y presentar
  evidencia durante una auditoría.
- **Criterio de ajuste:** El 100% de los depósitos, retiros, compras y
  ventas deberá generar un registro que incluya el identificador de la
  operación, el usuario, la fecha y hora, el importe, el estado anterior
  y el estado resultante. Estos registros no deberán poder modificarse ni
  eliminarse mediante las funciones normales de la plataforma.
- **Satisfacción / Insatisfacción del cliente:** 4 / 5.
- **Prioridad:** Must have.
- **Dependencias:** RNF-05 y RNF-07.
- **Conflictos:** La generación de registros puede afectar los tiempos
  definidos en RNF-03 y RNF-04, por lo que deberá implementarse sin
  bloquear innecesariamente el procesamiento de las operaciones.
- **Material de soporte:** HU-02, HU-04, HU-06 y ASR-03.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

#### Seguridad

**RNF-07: Confidencialidad de la información**

- **Evento/Caso de uso:** HU-01, Registro y verificación de identidad;
  HU-02, Depósito de fondos; HU-05, Consulta de portafolio y movimientos;
  HU-06, Retiro de fondos.
- **Descripción:** El sistema deberá proteger mediante cifrado la
  información personal y financiera de los usuarios durante su
  transmisión y almacenamiento.
- **Justificación:** InvestNow maneja documentos de identidad,
  información bancaria, movimientos y datos financieros cuya exposición
  puede afectar a los usuarios y generar incumplimientos regulatorios.
- **Criterio de ajuste:** Las pruebas de seguridad deberán verificar que
  el 100% de las comunicaciones externas que contengan información
  personal o financiera utilicen conexiones cifradas y que esa
  información permanezca cifrada en bases de datos, archivos y
  respaldos.
- **Satisfacción / Insatisfacción del cliente:** 5 / 5.
- **Prioridad:** Must have.
- **Dependencias:** RNF-08.
- **Conflictos:** El cifrado puede agregar tiempo de procesamiento, por
  lo que deberá considerarse junto con RNF-03.
- **Material de soporte:** Contexto de negocio, HU-01, HU-02, HU-05,
  HU-06 y ASR-01.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

**RNF-08: Segundo factor de autenticación**

- **Evento/Caso de uso:** HU-01, Registro y verificación de identidad;
  HU-06, Retiro de fondos.
- **Descripción:** El sistema deberá solicitar un segundo factor de
  autenticación antes de autorizar operaciones sensibles.
- **Justificación:** Una contraseña robada no debe ser suficiente para
  que un tercero pueda retirar fondos o modificar información bancaria.
- **Criterio de ajuste:** El 100% de los inicios de sesión desde un
  dispositivo no reconocido, los retiros de fondos y los cambios de
  cuenta bancaria deberán requerir un segundo factor de autenticación. La
  operación no deberá ejecutarse si el segundo factor no es validado
  correctamente.
- **Satisfacción / Insatisfacción del cliente:** 5 / 5.
- **Prioridad:** Must have.
- **Dependencias:** RNF-07.
- **Conflictos:** El segundo factor agrega un paso adicional para el
  usuario, pero no se identifican conflictos directos con otro
  requerimiento.
- **Material de soporte:** HU-01, HU-06 y contexto de negocio.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

#### Facilidad de modificación

**RNF-09: Incorporación de nuevos tipos de activos**

- **Evento/Caso de uso:** HU-07, Administración del catálogo de activos.
- **Descripción:** El sistema deberá permitir incorporar nuevos tipos de
  activos financieros sin modificar los componentes que no estén
  relacionados con la administración y operación de activos.
- **Justificación:** InvestNow necesita evolucionar para incorporar
  nuevos productos financieros y adaptarse a nuevas oportunidades
  comerciales.
- **Criterio de ajuste:** Un equipo de desarrollo familiarizado con la
  plataforma deberá poder incorporar un nuevo tipo de activo en un máximo
  de cinco días de trabajo, sin modificar los componentes de registro de
  usuarios, depósitos y retiros.
- **Satisfacción / Insatisfacción del cliente:** 4 / 4.
- **Prioridad:** Should have.
- **Dependencias:** RNF-10 y RNF-12.
- **Conflictos:** No se identifican conflictos directos.
- **Material de soporte:** Contexto de negocio, HU-07 y ASR-06.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

**RNF-10: Modificación de reglas de validación**

- **Evento/Caso de uso:** HU-04, Compra y venta de activos; HU-07,
  Administración del catálogo de activos.
- **Descripción:** El sistema deberá permitir modificar las reglas de
  validación de órdenes sin afectar los componentes que no estén
  relacionados con el procesamiento de órdenes.
- **Justificación:** Las regulaciones y reglas de operación pueden
  cambiar. InvestNow debe poder adaptarse sin introducir cambios
  innecesarios en otras partes de la plataforma.
- **Criterio de ajuste:** Un equipo de desarrollo familiarizado con la
  plataforma deberá poder modificar, probar y dejar disponible para
  despliegue una regla de validación de órdenes en un máximo de tres días
  de trabajo, sin modificar los componentes de cotizaciones, depósitos,
  retiros y administración de usuarios.
- **Satisfacción / Insatisfacción del cliente:** 4 / 5.
- **Prioridad:** Should have.
- **Dependencias:** RNF-12.
- **Conflictos:** No se identifican conflictos directos.
- **Material de soporte:** Contexto de negocio, HU-04 y HU-07.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

#### Facilidad de despliegue

**RNF-11: Despliegue sin interrupción del servicio**

- **Evento/Caso de uso:** Todas las historias de usuario relacionadas con
  las operaciones de la plataforma.
- **Descripción:** El sistema deberá permitir el despliegue de nuevas
  versiones sin interrumpir las operaciones de los usuarios.
- **Justificación:** InvestNow necesita incorporar correcciones y nuevas
  funcionalidades sin impedir que los usuarios consulten sus inversiones
  o realicen operaciones.
- **Criterio de ajuste:** Durante un despliegue realizado mediante una
  estrategia Blue/Green, la plataforma no deberá rechazar operaciones por
  causas atribuibles al despliegue y deberá permitir volver a la versión
  anterior en menos de cinco minutos.
- **Satisfacción / Insatisfacción del cliente:** 5 / 5.
- **Prioridad:** Must have.
- **Dependencias:** RNF-01, RNF-02 y RNF-12.
- **Conflictos:** No se identifican conflictos directos.
- **Material de soporte:** Contexto de negocio y estrategia de despliegue
  de InvestNow.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

**RNF-12: Automatización del proceso de despliegue**

- **Evento/Caso de uso:** Todas las historias de usuario relacionadas con
  las operaciones de la plataforma.
- **Descripción:** El sistema deberá permitir que las nuevas versiones
  sean validadas y desplegadas mediante un proceso automatizado de
  integración y despliegue continuo.
- **Justificación:** La automatización reduce los errores manuales y
  evita que una versión que no supera las pruebas obligatorias llegue al
  ambiente de producción.
- **Criterio de ajuste:** El pipeline de CI/CD deberá ejecutar las
  pruebas obligatorias y completar el despliegue en menos de 20 minutos.
  Si alguna prueba obligatoria falla, el proceso deberá detenerse sin
  modificar el ambiente de producción.
- **Satisfacción / Insatisfacción del cliente:** 4 / 4.
- **Prioridad:** Should have.
- **Dependencias:** RNF-09, RNF-10 y RNF-11.
- **Conflictos:** No se identifican conflictos directos.
- **Material de soporte:** Estrategia de despliegue y conjunto de pruebas
  automatizadas de InvestNow.
- **Historia:** Versión 1.0, agosto de 2026, creación inicial.

---

## Trazabilidad rápida

| ID     | Categoría                 | Prioridad   | HU relacionadas      |
|--------|----------------------------|-------------|------------------------|
| ASR-01 | Funcional (integración)    | Must have   | HU-01                 |
| ASR-02 | Funcional (integración)    | Must have   | HU-02, HU-06          |
| ASR-03 | Funcional (integración)    | Must have   | HU-03                 |
| ASR-04 | Funcional (integración)    | Must have   | HU-04                 |
| ASR-05 | Funcional (integración)    | Must have   | HU-04                 |
| ASR-06 | Funcional (integración)    | Must have   | HU-07                 |
| RNF-01 | Disponibilidad             | Must have   | HU-03, HU-04          |
| RNF-02 | Disponibilidad             | Must have   | HU-02, HU-04, HU-06   |
| RNF-03 | Rendimiento                | Must have   | HU-04                 |
| RNF-04 | Rendimiento                | Must have   | HU-04                 |
| RNF-05 | Protección                 | Must have   | HU-02, HU-04, HU-06   |
| RNF-06 | Protección                 | Must have   | HU-02, HU-04, HU-06   |
| RNF-07 | Seguridad                  | Must have   | HU-01, HU-02, HU-05, HU-06 |
| RNF-08 | Seguridad                  | Must have   | HU-01, HU-06          |
| RNF-09 | Facilidad de modificación  | Should have | HU-07                 |
| RNF-10 | Facilidad de modificación  | Should have | HU-04, HU-07          |
| RNF-11 | Facilidad de despliegue    | Must have   | (transversal)         |
| RNF-12 | Facilidad de despliegue    | Should have | (transversal)         |

Nota: la combinación de tácticas elegida para la demostración de UT2
(sanity checking, binding en tiempo de configuración y aspectos) instancia
en código un subconjunto acotado de estos RNF — ver
[`../UT2/ENTREGA.md`](../UT2/ENTREGA.md) para el detalle de esa elección.
