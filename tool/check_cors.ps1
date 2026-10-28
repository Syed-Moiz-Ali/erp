<#
.SYNOPSIS
  Probes the backend CORS preflight used by Flutter Web and reports whether the
  response carries the headers the browser requires.

.DESCRIPTION
  Reads API_BASE_URL from .env.development, sends the same OPTIONS preflight a
  browser sends for the JSON login request, and prints the response. Exit code 0
  when Access-Control-Allow-Origin is present, 1 when it is missing.

.EXAMPLE
  powershell -File tool/check_cors.ps1
  powershell -File tool/check_cors.ps1 -Origin http://localhost:62494
#>
param(
  [string]$Origin = 'http://localhost:8080',
  [string]$Path = '/api/auth/login'
)

$envFile = Join-Path $PSScriptRoot '..\.env.development'
$baseUrl = $null
if (Test-Path -LiteralPath $envFile) {
  $line = Get-Content -LiteralPath $envFile |
    Where-Object { $_ -match '^\s*API_BASE_URL\s*=' } |
    Select-Object -First 1
  if ($line) { $baseUrl = ($line -split '=', 2)[1].Trim() }
}
if (-not $baseUrl) {
  Write-Error 'API_BASE_URL not found in .env.development'
  exit 2
}

$uri = "$baseUrl$Path"
Write-Host "OPTIONS $uri" -ForegroundColor Cyan
Write-Host "Origin : $Origin"

$response = curl.exe -sS -i -X OPTIONS $uri `
  -H "Origin: $Origin" `
  -H 'Access-Control-Request-Method: POST' `
  -H 'Access-Control-Request-Headers: content-type,authorization,x-request-id,x-client-platform' `
  --max-time 25

$response | ForEach-Object { Write-Host $_ }

if ($response | Select-String -Pattern '^Access-Control-Allow-Origin:' -Quiet) {
  Write-Host "`nCORS: OK (Access-Control-Allow-Origin present)" -ForegroundColor Green
  exit 0
}

Write-Host "`nCORS: FAILED (no Access-Control-Allow-Origin)." -ForegroundColor Red
Write-Host 'Enable CORS on the backend and place UseCors BEFORE UseAuthentication/UseAuthorization'
Write-Host 'so the preflight returns 204 with CORS headers instead of 401.'
exit 1
