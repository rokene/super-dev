#!/usr/bin/env bash

set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/versions.sh"

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(eval echo "~${TARGET_USER}")"
NVM_DIR="${TARGET_HOME}/.nvm"
NVM_VERSION="${NVM_VERSION:-v0.39.7}"
NODE_VERSION="${NODE_VERSION:-22}"

echo "installing NVM ${NVM_VERSION} for the ${TARGET_USER} user"
if [ ! -s "${NVM_DIR}/nvm.sh" ]; then
  su - "${TARGET_USER}" -c "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash"
fi

echo "ensuring NVM is loaded from .bashrc"
BASHRC="${TARGET_HOME}/.bashrc"

grep -qxF 'export NVM_DIR="$HOME/.nvm"' "${BASHRC}" || \
  echo 'export NVM_DIR="$HOME/.nvm"' >> "${BASHRC}"

grep -qxF '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' "${BASHRC}" || \
  echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "${BASHRC}"

grep -qxF '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' "${BASHRC}" || \
  echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "${BASHRC}"

echo "installing Node.js ${NODE_VERSION} for the ${TARGET_USER} user"
su - "${TARGET_USER}" -c "
  export NVM_DIR=\"\$HOME/.nvm\"
  [ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"
  nvm install ${NODE_VERSION}
  nvm alias default ${NODE_VERSION}
  nvm use default
  node --version
  npm --version
"
