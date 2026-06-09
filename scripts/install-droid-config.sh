#!/usr/bin/env bash
#
# install-droid-config.sh - Instala los modelos custom de droid (Factory).
#
# Anade los modelos del proxy a ~/.factory/settings.json. Si ya tienes un
# settings.json, se respalda antes de reemplazarlo.
#
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${PROJECT_DIR}/droid/settings.json"
DEST_DIR="${HOME}/.factory"
DEST="${DEST_DIR}/settings.json"

if [ ! -f "$SRC" ]; then
  echo "[droid] No se encuentra ${SRC}" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"

if [ -f "$DEST" ]; then
  backup="${DEST}.bak.$(date +%Y%m%d%H%M%S)"
  cp "$DEST" "$backup"
  echo "[droid] Config existente respaldada en: $backup"
fi

cp "$SRC" "$DEST"
echo "[droid] Config instalada en: $DEST"
echo "[droid] Listo. Con el proxy corriendo, abre 'droid' y elige un modelo (Subscription via Proxy)."
