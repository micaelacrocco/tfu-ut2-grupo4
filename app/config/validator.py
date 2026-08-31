"""Sanity checking: valida la config cruda antes de levantar el servidor (RNF-03)."""

ALLOWED_MODES = ("friendly", "formal")


def validate(raw: dict) -> list[str]:
    errors = []

    port = raw.get("server", {}).get("port")
    if not isinstance(port, int):
        errors.append(f"server.port debe ser un número entero, se recibió: {port!r}")

    mode = raw.get("business", {}).get("mode")
    if mode not in ALLOWED_MODES:
        errors.append(
            f"business.mode debe ser uno de {ALLOWED_MODES}, se recibió: {mode!r}"
        )

    greeting_message = raw.get("business", {}).get("greeting_message")
    if not greeting_message:
        errors.append("business.greeting_message es obligatorio y no puede estar vacío")

    return errors
