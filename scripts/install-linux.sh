#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES_DIR="$ROOT_DIR/templates"
TARGET_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"

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

echo "Done."
echo "Next steps:"
echo "1) Add keys locally with: opencode auth login <provider>"
echo "2) Verify with: bunx oh-my-opencode doctor --verbose"
