#!/usr/bin/env bash
#
# install-opencode-config.sh - Copia la config de opencode al lugar correcto.
#
# Copia opencode.jsonc a ~/.config/opencode/opencode.jsonc para que opencode
# use el proxy local CLIProxyAPI.
#
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${PROJECT_DIR}/opencode/opencode.jsonc"
DEST_DIR="${HOME}/.config/opencode"
DEST="${DEST_DIR}/opencode.jsonc"

if [ ! -f "$SRC" ]; then
  echo "[opencode] No se encuentra ${SRC}" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"

if [ -f "$DEST" ]; then
  backup="${DEST}.bak.$(date +%Y%m%d%H%M%S)"
  cp "$DEST" "$backup"
  echo "[opencode] Config existente respaldada en: $backup"
fi

cp "$SRC" "$DEST"
echo "[opencode] Config instalada en: $DEST"
echo "[opencode] Listo. Con el proxy corriendo, abre 'opencode' y elige un modelo cliproxy/..."
