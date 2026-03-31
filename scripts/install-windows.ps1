$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -Parent
$TemplatesDir = Join-Path $RootDir "templates"
$TargetDir = Join-Path $env:USERPROFILE ".config\opencode"
$ToolsDir = Join-Path $env:USERPROFILE ".opencode-tools"

if (-not $env:INSTALL_PROMPTFOO) { $env:INSTALL_PROMPTFOO = "1" }
if (-not $env:INSTALL_OPENVIKING) { $env:INSTALL_OPENVIKING = "0" }
if (-not $env:INSTALL_IMPECCABLE) { $env:INSTALL_IMPECCABLE = "0" }

Write-Host "Installing OpenCode config to: $TargetDir"
New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
Copy-Item (Join-Path $TemplatesDir "opencode.json") (Join-Path $TargetDir "opencode.json") -Force
Copy-Item (Join-Path $TemplatesDir "oh-my-opencode.json") (Join-Path $TargetDir "oh-my-opencode.json") -Force
New-Item -ItemType Directory -Path (Join-Path $TargetDir "scripts") -Force | Out-Null
Copy-Item (Join-Path $TemplatesDir "scripts\openviking-mcp.js") (Join-Path $TargetDir "scripts\openviking-mcp.js") -Force

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

if ($env:INSTALL_PROMPTFOO -eq "1") {
  Write-Host "Installing Promptfoo..."
  if (Get-Command npm -ErrorAction SilentlyContinue) {
    npm install -g promptfoo
  } elseif (Get-Command bun -ErrorAction SilentlyContinue) {
    bun add -g promptfoo
  } else {
    Write-Host "Skipping Promptfoo install: bun/npm not found"
  }
}

if ($env:INSTALL_OPENVIKING -eq "1") {
  $OpenVikingDir = Join-Path $ToolsDir "openviking"
  New-Item -ItemType Directory -Path $ToolsDir -Force | Out-Null
  if (Test-Path (Join-Path $OpenVikingDir ".git")) {
    git -C $OpenVikingDir pull --ff-only
  } else {
    git clone https://github.com/volcengine/OpenViking $OpenVikingDir
  }
  Write-Host "OpenViking repo synced. Use its README to run Docker/services."
}

if ($env:INSTALL_IMPECCABLE -eq "1") {
  $ImpeccableDir = Join-Path $ToolsDir "impeccable"
  New-Item -ItemType Directory -Path $ToolsDir -Force | Out-Null
  if (Test-Path (Join-Path $ImpeccableDir ".git")) {
    git -C $ImpeccableDir pull --ff-only
  } else {
    git clone https://github.com/pbakaus/impeccable $ImpeccableDir
  }
}

Write-Host "Done."
Write-Host "Next steps:"
Write-Host "1) Add keys locally with: opencode auth login <provider>"
Write-Host "2) Verify with: bunx oh-my-opencode doctor --verbose"
Write-Host "3) Optional env toggles: INSTALL_PROMPTFOO=1 INSTALL_OPENVIKING=1 INSTALL_IMPECCABLE=1"
