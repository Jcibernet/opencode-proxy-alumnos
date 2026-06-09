# install-opencode-config.ps1 - Instala la config global de opencode.
# Uso: .\scripts\install-opencode-config.ps1

$ErrorActionPreference = "Stop"
$ProjectDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Src = Join-Path $ProjectDir "opencode\opencode.jsonc"
$DestDir = Join-Path $HOME ".config\opencode"
$Dest = Join-Path $DestDir "opencode.jsonc"

if (-not (Test-Path $Src)) { throw "No se encuentra $Src" }
New-Item -ItemType Directory -Force -Path $DestDir | Out-Null

if (Test-Path $Dest) {
  $backup = "$Dest.bak.$(Get-Date -Format yyyyMMddHHmmss)"
  Copy-Item $Dest $backup
  Write-Host "[opencode] Config existente respaldada en: $backup" -ForegroundColor Yellow
}

Copy-Item $Src $Dest -Force
Write-Host "[opencode] Config instalada en: $Dest" -ForegroundColor Cyan
Write-Host "[opencode] Reinicia opencode y usa /models para elegir un modelo disponible."
