#!/usr/bin/env bash
set -euo pipefail

echo "── 1. Postgres descartable ──────────────────────────"
docker run -d --name caso13-db -e POSTGRES_PASSWORD=dev -p 55432:5432 postgres:17-alpine
until docker exec caso13-db pg_isready -U postgres -q; do sleep 1; done
docker exec caso13-db psql -U postgres -c "CREATE TABLE demo(id int); INSERT INTO demo VALUES (1),(2),(3);"
docker exec caso13-db psql -U postgres -t -c "SELECT 'filas en el Postgres del contenedor: ' || COUNT(*) FROM demo;"
docker rm -f caso13-db > /dev/null
echo "✔ contenedor destruido: no quedó NADA instalado en tu máquina"

echo "── 2. tu primera imagen ─────────────────────────────"
docker build -q -t caso13-app .
docker run --rm caso13-app
docker rmi -f caso13-app > /dev/null
echo "✔ imagen construida, corrida y borrada — el ciclo completo"
