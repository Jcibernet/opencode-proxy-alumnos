# login.ps1 - Login web OAuth con Anthropic o OpenAI.
# Uso: .\scripts\login.ps1 anthropic  |  .\scripts\login.ps1 openai

param(
  [string]$Provider = "",
  [switch]$NoBrowser
)

$ErrorActionPreference = "Stop"
$ProjectDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$BinPath = Join-Path $ProjectDir "bin\cli-proxy-api.exe"
$ConfigPath = Join-Path $ProjectDir "config.yaml"

if (-not (Test-Path $BinPath)) {
  Write-Error "No se encuentra el binario. Ejecuta primero: powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1"
}

if ([string]::IsNullOrWhiteSpace($Provider)) {
  Write-Host "Elige con que cuenta quieres iniciar sesion:"
  Write-Host "  1) Anthropic (modelos Claude)"
  Write-Host "  2) OpenAI    (modelos GPT / Codex)"
  $opt = Read-Host "Opcion [1-2]"
  if ($opt -eq "1") { $Provider = "anthropic" }
  elseif ($opt -eq "2") { $Provider = "openai" }
  else { throw "Opcion invalida." }
}

$flag = switch ($Provider.ToLowerInvariant()) {
  { $_ -in @("anthropic", "claude") } { "-claude-login"; break }
  { $_ -in @("openai", "codex", "gpt") } { "-codex-login"; break }
  default { throw "Proveedor desconocido: $Provider. Usa anthropic u openai." }
}

$argsList = @("--config", $ConfigPath, $flag)
if ($NoBrowser) { $argsList += "--no-browser" }

Write-Host "[login] Abriendo flujo OAuth ($flag)..." -ForegroundColor Cyan
& $BinPath @argsList
