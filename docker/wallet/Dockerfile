FROM python:3.12-slim

WORKDIR /app

# Instalar dependencias de Python
COPY docker/order/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el código fuente
COPY app app

EXPOSE 8000

# Comando de arranque específico para la wallet
CMD ["python", "-m", "app.wallet_main"]