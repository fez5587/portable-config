# OpenCode Portable Config

This folder is safe to commit to GitHub. It contains config and installers, but no API keys.

## What is included

- `templates/opencode.json`
- `templates/oh-my-opencode.json`
- `scripts/install-linux.sh`
- `scripts/install-windows.ps1`
- `.env.example`

## How to use

1. Push this folder to your GitHub repo.
2. On a target machine, clone or download the repo.
3. Run the platform installer from `scripts/`.
4. Copy `.env.example` to `.env` and fill keys locally.
5. Run `opencode auth login <provider>` or `/connect` in OpenCode.

## Important

- Do not commit `.env`.
- Do not commit `~/.local/share/opencode/auth.json`.
- Credentials should always be entered locally on each machine.
