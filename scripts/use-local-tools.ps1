$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ToolPaths = @(
  Join-Path $RepoRoot ".tools\node"
  Join-Path $RepoRoot ".tools\kubectl"
  Join-Path $RepoRoot ".tools\kustomize"
)

$env:PATH = (($ToolPaths + $env:PATH.Split(";")) | Where-Object { $_ } | Select-Object -Unique) -join ";"

Write-Host "Local tools are active for this PowerShell session."
Write-Host "Use npm.cmd instead of npm if PowerShell blocks npm.ps1."
