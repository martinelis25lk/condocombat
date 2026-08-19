#!/bin/bash
set -e

if [ -z "$SECRET_KEY" ]; then
    echo "ERRO: SECRET_KEY nao esta definida!"
    exit 1
fi

echo "Rodando migrations do Alembic..."
alembic upgrade head

echo "Iniciando servidor FastAPI..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000
