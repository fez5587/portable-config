#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES_DIR="$ROOT_DIR/templates"
TARGET_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
TOOLS_DIR="$HOME/.local/share/opencode-tools"

INSTALL_PROMPTFOO="${INSTALL_PROMPTFOO:-1}"
INSTALL_OPENVIKING="${INSTALL_OPENVIKING:-0}"
INSTALL_IMPECCABLE="${INSTALL_IMPECCABLE:-0}"

echo "Installing OpenCode config to: $TARGET_DIR"
mkdir -p "$TARGET_DIR"
cp "$TEMPLATES_DIR/opencode.json" "$TARGET_DIR/opencode.json"
cp "$TEMPLATES_DIR/oh-my-opencode.json" "$TARGET_DIR/oh-my-opencode.json"

echo "Installing optional components (Node/Bun packages)..."
if command -v bun >/dev/null 2>&1; then
  (cd "$TARGET_DIR" && bun add @opencode-ai/plugin @code-yeongyu/comment-checker)
elif command -v npm >/dev/null 2>&1; then
  (cd "$TARGET_DIR" && npm install @opencode-ai/plugin @code-yeongyu/comment-checker)
else
  echo "Skipping package install: bun/npm not found"
fi

if [[ "$INSTALL_PROMPTFOO" == "1" ]]; then
  echo "Installing Promptfoo..."
  if command -v npm >/dev/null 2>&1; then
    npm install -g promptfoo
  elif command -v bun >/dev/null 2>&1; then
    bun add -g promptfoo
  else
    echo "Skipping Promptfoo install: bun/npm not found"
  fi
fi

if [[ "$INSTALL_OPENVIKING" == "1" ]]; then
  echo "Installing OpenViking files to $TOOLS_DIR/openviking..."
  mkdir -p "$TOOLS_DIR"
  if [[ -d "$TOOLS_DIR/openviking/.git" ]]; then
    git -C "$TOOLS_DIR/openviking" pull --ff-only
  else
    git clone https://github.com/volcengine/OpenViking "$TOOLS_DIR/openviking"
  fi
  echo "OpenViking repo synced. Use its README to run Docker/services."
fi

if [[ "$INSTALL_IMPECCABLE" == "1" ]]; then
  echo "Installing Impeccable skills repo to $TOOLS_DIR/impeccable..."
  mkdir -p "$TOOLS_DIR"
  if [[ -d "$TOOLS_DIR/impeccable/.git" ]]; then
    git -C "$TOOLS_DIR/impeccable" pull --ff-only
  else
    git clone https://github.com/pbakaus/impeccable "$TOOLS_DIR/impeccable"
  fi
fi

echo "Done."
echo "Next steps:"
echo "1) Add keys locally with: opencode auth login <provider>"
echo "2) Verify with: bunx oh-my-opencode doctor --verbose"
echo "3) Optional toggles: INSTALL_PROMPTFOO=1 INSTALL_OPENVIKING=1 INSTALL_IMPECCABLE=1"
