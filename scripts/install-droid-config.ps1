# install-droid-config.ps1 - Instala los modelos custom de droid (Factory).
# Uso: .\scripts\install-droid-config.ps1

$ErrorActionPreference = "Stop"
$ProjectDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Src = Join-Path $ProjectDir "droid\settings.json"
$DestDir = Join-Path $HOME ".factory"
$Dest = Join-Path $DestDir "settings.json"

if (-not (Test-Path $Src)) { throw "No se encuentra $Src" }
New-Item -ItemType Directory -Force -Path $DestDir | Out-Null

if (Test-Path $Dest) {
  $backup = "$Dest.bak.$(Get-Date -Format yyyyMMddHHmmss)"
  Copy-Item $Dest $backup
  Write-Host "[droid] Config existente respaldada en: $backup" -ForegroundColor Yellow
}

Copy-Item $Src $Dest -Force
Write-Host "[droid] Config instalada en: $Dest" -ForegroundColor Cyan
Write-Host "[droid] Abre droid y elige un modelo '(Subscription via Proxy)'."
