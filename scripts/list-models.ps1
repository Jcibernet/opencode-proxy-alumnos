# list-models.ps1 - Muestra modelos reales disponibles en el proxy local.
# Uso: .\scripts\list-models.ps1

$ErrorActionPreference = "Stop"
$Url = "http://127.0.0.1:8317/v1/models"

try {
  $data = Invoke-RestMethod $Url
} catch {
  Write-Host "[list-models] El proxy no responde en $Url" -ForegroundColor Yellow
  Write-Host "[list-models] Primero corre: .\scripts\proxy-start.ps1"
  exit 1
}

$data.data | Sort-Object owned_by, id | ForEach-Object {
  Write-Host "$($_.owned_by): $($_.id)"
}
