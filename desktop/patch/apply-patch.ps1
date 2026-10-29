param(
  [string]$InstallDir = "$env:LOCALAPPDATA\Programs\FreeLLMAPI"
)

$ErrorActionPreference = 'Stop'
$resources = Join-Path $InstallDir 'resources'
$patchResources = Join-Path $PSScriptRoot 'resources'

if (-not (Test-Path (Join-Path $resources 'app.asar'))) {
  throw "FreeLLMAPI installation not found at $InstallDir. Pass -InstallDir with the folder containing FreeLLMAPI.exe."
}
if (-not (Test-Path (Join-Path $patchResources 'app.asar'))) {
  throw 'This patch is incomplete: resources/app.asar is missing.'
}

Get-Process FreeLLMAPI -ErrorAction SilentlyContinue | Stop-Process -Force

$backup = Join-Path $InstallDir ("patch-backup-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $backup | Out-Null
Copy-Item (Join-Path $resources 'app.asar') (Join-Path $backup 'app.asar')
if (Test-Path (Join-Path $resources 'client-dist')) {
  Copy-Item (Join-Path $resources 'client-dist') (Join-Path $backup 'client-dist') -Recurse
}

Copy-Item (Join-Path $patchResources 'app.asar') (Join-Path $resources 'app.asar') -Force
if (Test-Path (Join-Path $patchResources 'client-dist')) {
  Remove-Item (Join-Path $resources 'client-dist') -Recurse -Force
  Copy-Item (Join-Path $patchResources 'client-dist') (Join-Path $resources 'client-dist') -Recurse
}

Write-Host "FreeLLMAPI patch applied. Backup: $backup"
