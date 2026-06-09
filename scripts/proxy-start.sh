#!/usr/bin/env bash
#
# proxy-start.sh - Arranca el servidor CLIProxyAPI con la config local.
#
# Equivalente al alias `proxy-start`. Una vez corriendo, el proxy escucha en
# http://127.0.0.1:8317 y opencode puede usarlo.
#
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_PATH="${PROJECT_DIR}/bin/cli-proxy-api"
CONFIG_PATH="${PROJECT_DIR}/config.yaml"

if [ ! -x "$BIN_PATH" ]; then
  echo "[proxy-start] No se encuentra el binario. Ejecuta primero: ./scripts/setup.sh" >&2
  exit 1
fi

if [ ! -f "$CONFIG_PATH" ]; then
  echo "[proxy-start] No se encuentra config.yaml. Ejecuta primero: ./scripts/setup.sh" >&2
  exit 1
fi

echo "[proxy-start] Iniciando CLIProxyAPI en http://127.0.0.1:8317 ..."
echo "[proxy-start] Deten con Ctrl+C."
exec "$BIN_PATH" --config "$CONFIG_PATH"
