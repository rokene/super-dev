#!/usr/bin/env bash

set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/versions.sh"

# Determine target user: prefer SUDO_USER if run with sudo, fallback to current user
TARGET_USER="${SUDO_USER:-$USER}"

echo "#### installing Claude Code CLI for user: ${TARGET_USER}"

su - "${TARGET_USER}" -c "
  export NVM_DIR=\"\$HOME/.nvm\"
  [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"

  npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}
"

echo
echo "==== Claude Code Version ===="

su - "${TARGET_USER}" -c "
  export NVM_DIR=\"\$HOME/.nvm\"
  [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"

  claude --version
"

echo "============================="
