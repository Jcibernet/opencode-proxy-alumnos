# setup.ps1 - Descarga el binario oficial de CLIProxyAPI y prepara config.yaml.
# Uso: powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1

$ErrorActionPreference = "Stop"

$Repo = "router-for-me/CLIProxyAPI"
$ProjectDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$BinDir = Join-Path $ProjectDir "bin"
$BinPath = Join-Path $BinDir "cli-proxy-api.exe"

function Info($Message) { Write-Host "[setup] $Message" -ForegroundColor Cyan }

function Get-PlatformParts {
  $archRaw = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
  $archRaw = $archRaw.ToLowerInvariant()
  switch ($archRaw) {
    { $_ -in @("amd64", "x64") } { $arch = "amd64"; break }
    { $_ -in @("arm64", "aarch64") } { $arch = "arm64"; break }
    default { throw "Arquitectura no soportada: $archRaw" }
  }
  return @("windows", $arch)
}

if (Test-Path $BinPath) {
  Info "El binario ya existe en $BinPath. Omitiendo descarga."
} else {
  $parts = Get-PlatformParts
  $os = $parts[0]
  $arch = $parts[1]
  Info "Plataforma detectada: $os/$arch"
  Info "Buscando el ultimo release de $Repo..."

  $release = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest"
  $asset = $release.assets | Where-Object {
    $_.name -match $os -and $_.name -match $arch -and $_.name -match "\.zip$"
  } | Select-Object -First 1

  if (-not $asset) {
    throw "No se encontro binario Windows/$arch. Descargalo manualmente desde https://github.com/$Repo/releases"
  }

  New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
  $tmp = New-Item -ItemType Directory -Force -Path (Join-Path ([System.IO.Path]::GetTempPath()) ("cliproxy-" + [guid]::NewGuid()))
  $zip = Join-Path $tmp.FullName "asset.zip"

  Info "Descargando $($asset.browser_download_url)"
  Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zip
  Expand-Archive -Path $zip -DestinationPath $tmp.FullName -Force

  $found = Get-ChildItem -Path $tmp.FullName -Recurse -File | Where-Object { $_.Name -in @("cli-proxy-api.exe", "cli-proxy-api") } | Select-Object -First 1
  if (-not $found) { throw "No se encontro cli-proxy-api dentro del paquete descargado." }
  Copy-Item $found.FullName $BinPath -Force
  Remove-Item $tmp.FullName -Recurse -Force
  Info "Binario instalado en $BinPath"
}

$Config = Join-Path $ProjectDir "config.yaml"
$Example = Join-Path $ProjectDir "config.example.yaml"
if (-not (Test-Path $Config)) {
  Copy-Item $Example $Config
  Info "Creado config.yaml a partir de config.example.yaml"
} else {
  Info "config.yaml ya existe. No se sobrescribe."
}

Info "Listo. Siguientes pasos:"
Info "  1) .\scripts\login.ps1"
Info "  2) .\scripts\proxy-start.ps1"
Info "  3) .\scripts\install-opencode-config.ps1 o .\scripts\install-droid-config.ps1"
