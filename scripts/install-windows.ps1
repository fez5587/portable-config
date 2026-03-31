$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -Parent
$TemplatesDir = Join-Path $RootDir "templates"
$TargetDir = Join-Path $env:USERPROFILE ".config\opencode"

Write-Host "Installing OpenCode config to: $TargetDir"
New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
Copy-Item (Join-Path $TemplatesDir "opencode.json") (Join-Path $TargetDir "opencode.json") -Force
Copy-Item (Join-Path $TemplatesDir "oh-my-opencode.json") (Join-Path $TargetDir "oh-my-opencode.json") -Force

Write-Host "Installing optional components (Node/Bun packages)..."
if (Get-Command bun -ErrorAction SilentlyContinue) {
  Push-Location $TargetDir
  bun add @opencode-ai/plugin @code-yeongyu/comment-checker
  Pop-Location
} elseif (Get-Command npm -ErrorAction SilentlyContinue) {
  Push-Location $TargetDir
  npm install @opencode-ai/plugin @code-yeongyu/comment-checker
  Pop-Location
} else {
  Write-Host "Skipping package install: bun/npm not found"
}

Write-Host "Done."
Write-Host "Next steps:"
Write-Host "1) Add keys locally with: opencode auth login <provider>"
Write-Host "2) Verify with: bunx oh-my-opencode doctor --verbose"
