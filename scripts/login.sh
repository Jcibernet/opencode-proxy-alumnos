#!/usr/bin/env bash
#
# login.sh - Inicia sesion web (OAuth) con tu propia cuenta.
#
# Abre el navegador para que inicies sesion con tu cuenta personal de
# Anthropic (Claude) o de OpenAI (GPT/Codex). Las credenciales se guardan
# localmente en ~/.cli-proxy-api y NUNCA se suben a git.
#
# Uso:
#   ./scripts/login.sh                # menu interactivo
#   ./scripts/login.sh anthropic      # login con Anthropic (Claude)
#   ./scripts/login.sh openai         # login con OpenAI (GPT/Codex)
#
# Si estas en un servidor sin navegador, agrega --no-browser y copia la URL:
#   ./scripts/login.sh anthropic --no-browser
#
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_PATH="${PROJECT_DIR}/bin/cli-proxy-api"
CONFIG_PATH="${PROJECT_DIR}/config.yaml"

if [ ! -x "$BIN_PATH" ]; then
  echo "[login] No se encuentra el binario. Ejecuta primero: ./scripts/setup.sh" >&2
  exit 1
fi

PROVIDER="${1:-}"
shift || true
EXTRA_ARGS=("$@")

run_login() {
  local flag="$1"
  echo "[login] Abriendo flujo OAuth ($flag)..."
  exec "$BIN_PATH" --config "$CONFIG_PATH" "$flag" "${EXTRA_ARGS[@]}"
}

case "$PROVIDER" in
  anthropic|claude)     run_login "-claude-login" ;;
  openai|codex|gpt)     run_login "-codex-login" ;;
  "")
    echo "Elige con que cuenta quieres iniciar sesion:"
    echo "  1) Anthropic (modelos Claude)  <- recomendado"
    echo "  2) OpenAI    (modelos GPT / Codex)"
    read -rp "Opcion [1-2]: " opt
    case "$opt" in
      1) run_login "-claude-login" ;;
      2) run_login "-codex-login" ;;
      *) echo "[login] Opcion invalida." >&2; exit 1 ;;
    esac
    ;;
  *)
    echo "[login] Proveedor desconocido: $PROVIDER" >&2
    echo "Usa: anthropic | openai" >&2
    exit 1
    ;;
esac
