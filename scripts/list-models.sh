#!/usr/bin/env bash
#
# list-models.sh - Muestra los modelos reales disponibles en tu proxy local.
#
set -euo pipefail

URL="http://127.0.0.1:8317/v1/models"

if ! command -v curl >/dev/null 2>&1; then
  echo "[list-models] Necesitas curl instalado." >&2
  exit 1
fi

json="$(curl -fsS "$URL" 2>/dev/null || true)"
if [ -z "$json" ]; then
  echo "[list-models] El proxy no responde en $URL"
  echo "[list-models] Primero corre: ./scripts/proxy-start.sh"
  exit 1
fi

if command -v python3 >/dev/null 2>&1; then
  printf '%s' "$json" | python3 -c 'import json,sys
d=json.load(sys.stdin)
rows=[]
for m in d.get("data",[]):
    rows.append((m.get("owned_by","unknown"), m.get("id","")))
for owner, model in sorted(rows):
    print(f"{owner}: {model}")'
else
  echo "$json"
fi
