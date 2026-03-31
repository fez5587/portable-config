# OpenCode Portable Config

This folder is safe to commit to GitHub. It contains config and installers, but no API keys.

## What is included

- `templates/opencode.json`
- `templates/oh-my-opencode.json`
- `scripts/install-linux.sh`
- `scripts/install-windows.ps1`
- `.env.example`
- `OBSIDIAN_KNOWLEDGE_WORKFLOW.md`

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

## Important

- Do not commit `.env`.
- Do not commit `~/.local/share/opencode/auth.json`.
- Credentials should always be entered locally on each machine.
