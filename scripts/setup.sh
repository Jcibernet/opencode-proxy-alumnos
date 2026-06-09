#!/usr/bin/env bash
#
# setup.sh - Descarga el binario oficial de CLIProxyAPI y prepara la config.
#
# Uso:
#   ./scripts/setup.sh
#
# No necesitas Go ni Docker. Solo curl/tar y conexion a internet.
#
set -euo pipefail

REPO="router-for-me/CLIProxyAPI"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="${PROJECT_DIR}/bin"
BIN_PATH="${BIN_DIR}/cli-proxy-api"

info()  { printf '\033[1;34m[setup]\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[setup]\033[0m %s\n' "$*"; }
error() { printf '\033[1;31m[setup]\033[0m %s\n' "$*" >&2; }

# --- Detectar SO y arquitectura ---------------------------------------------
detect_platform() {
  local os arch
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m)"

  case "$os" in
    linux)  os="linux" ;;
    darwin) os="darwin" ;;
    msys*|mingw*|cygwin*) os="windows" ;;
    *) error "Sistema operativo no soportado: $os"; exit 1 ;;
  esac

  case "$arch" in
    x86_64|amd64) arch="amd64" ;;
    arm64|aarch64) arch="arm64" ;;
    *) error "Arquitectura no soportada: $arch"; exit 1 ;;
  esac

  echo "${os} ${arch}"
}

# --- Obtener URL del ultimo release -----------------------------------------
latest_asset_url() {
  local os="$1" arch="$2"
  local api="https://api.github.com/repos/${REPO}/releases/latest"
  local pattern="${os}.*${arch}"

  # Asegura coincidir tar.gz para unix y zip para windows.
  local ext="tar.gz"
  [ "$os" = "windows" ] && ext="zip"

  curl -fsSL "$api" \
    | grep -oE '"browser_download_url": *"[^"]+"' \
    | sed -E 's/"browser_download_url": *"([^"]+)"/\1/' \
    | grep -iE "$pattern" \
    | grep -iE "\.${ext}$" \
    | head -n1
}

main() {
  read -r OS ARCH <<<"$(detect_platform)"
  info "Plataforma detectada: ${OS}/${ARCH}"

  if [ -x "$BIN_PATH" ]; then
    info "El binario ya existe en ${BIN_PATH}. Omitiendo descarga."
  else
    info "Buscando el ultimo release de ${REPO}..."
    local url
    url="$(latest_asset_url "$OS" "$ARCH")"
    if [ -z "$url" ]; then
      error "No se encontro un binario para ${OS}/${ARCH}."
      error "Descargalo manualmente desde: https://github.com/${REPO}/releases"
      exit 1
    fi

    info "Descargando: $url"
    mkdir -p "$BIN_DIR"
    local tmp
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT

    local file="${tmp}/asset"
    curl -fsSL "$url" -o "$file"

    info "Extrayendo binario..."
    if [[ "$url" == *.zip ]]; then
      unzip -o -q "$file" -d "$tmp"
    else
      tar -xzf "$file" -C "$tmp"
    fi

    # Localiza el ejecutable extraido.
    local found
    found="$(find "$tmp" -type f \( -name 'cli-proxy-api' -o -name 'cli-proxy-api.exe' \) | head -n1)"
    if [ -z "$found" ]; then
      error "No se encontro el ejecutable cli-proxy-api dentro del paquete."
      exit 1
    fi
    cp "$found" "$BIN_PATH"
    chmod +x "$BIN_PATH"
    info "Binario instalado en ${BIN_PATH}"
  fi

  # --- Preparar config.yaml ---------------------------------------------------
  if [ ! -f "${PROJECT_DIR}/config.yaml" ]; then
    cp "${PROJECT_DIR}/config.example.yaml" "${PROJECT_DIR}/config.yaml"
    info "Creado config.yaml a partir de config.example.yaml"
  else
    info "config.yaml ya existe. No se sobrescribe."
  fi

  info ""
  info "Listo. Siguientes pasos:"
  info "  1) Inicia sesion con tu cuenta:   ./scripts/login.sh"
  info "  2) Arranca el proxy:              ./scripts/proxy-start.sh"
  info "  3) Configura opencode:            ./scripts/install-opencode-config.sh"
}

main "$@"
