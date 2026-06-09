# proxy-start.ps1 - Arranca CLIProxyAPI en http://127.0.0.1:8317.
# Uso: .\scripts\proxy-start.ps1

$ErrorActionPreference = "Stop"
$ProjectDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$BinPath = Join-Path $ProjectDir "bin\cli-proxy-api.exe"
$ConfigPath = Join-Path $ProjectDir "config.yaml"

if (-not (Test-Path $BinPath)) {
  Write-Error "No se encuentra el binario. Ejecuta primero: powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1"
}
if (-not (Test-Path $ConfigPath)) {
  Write-Error "No se encuentra config.yaml. Ejecuta primero setup.ps1"
}

Write-Host "[proxy-start] Iniciando CLIProxyAPI en http://127.0.0.1:8317 ..." -ForegroundColor Cyan
Write-Host "[proxy-start] Deten con Ctrl+C."
& $BinPath --config $ConfigPath
