# OpenCode Portable Config

This folder is safe to commit to GitHub. It contains config and installers, but no API keys.

## What is included

- `templates/opencode.json`
- `templates/oh-my-opencode.json`
- `templates/scripts/openviking-mcp.js`
- `scripts/install-linux.sh`
- `scripts/install-windows.ps1`
- `.env.example`
- `OBSIDIAN_KNOWLEDGE_WORKFLOW.md`
- `MEMORY_FIRST_POLICY.md`

## How to use

1. Push this folder to your GitHub repo.
2. On a target machine, clone or download the repo.
3. Run the platform installer from `scripts/`.
4. Copy `.env.example` to `.env` and fill keys locally.
5. Run `opencode auth login <provider>` or `/connect` in OpenCode.

### Optional enhancements toggles

Linux:

```bash
INSTALL_PROMPTFOO=1 INSTALL_OPENVIKING=1 INSTALL_IMPECCABLE=1 bash scripts/install-linux.sh
```

Windows PowerShell:

```powershell
$env:INSTALL_PROMPTFOO="1"
$env:INSTALL_OPENVIKING="1"
$env:INSTALL_IMPECCABLE="1"
.\scripts\install-windows.ps1
```

## OpenViking MCP bridge

The bundle includes a local OpenViking bridge script (`scripts/openviking-mcp.js`).

- Default OpenViking server URL: `http://127.0.0.1:1933`
- Override with env var: `OPENVIKING_BASE_URL`
- Tools exposed to OpenCode:
  - `openviking_search`
  - `openviking_read`
  - `openviking_upsert`

## Important

- Do not commit `.env`.
- Do not commit `~/.local/share/opencode/auth.json`.
- Credentials should always be entered locally on each machine.
