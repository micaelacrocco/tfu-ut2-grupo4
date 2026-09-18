-- Se ejecuta una única vez, la primera vez que se crea el volumen de Postgres
-- (ver docker-entrypoint-initdb.d en la imagen oficial de postgres).

CREATE TABLE IF NOT EXISTS wallets (
    user_id INTEGER PRIMARY KEY,
    balance NUMERIC(14, 2) NOT NULL CHECK (balance >= 0)
);

INSERT INTO wallets (user_id, balance) VALUES
    (1, 10000.00),
    (2, 500.00)
ON CONFLICT (user_id) DO NOTHING;
