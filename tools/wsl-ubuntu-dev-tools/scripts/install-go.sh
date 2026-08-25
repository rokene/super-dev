#!/usr/bin/env bash

set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/versions.sh"

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_GROUP="$(id -gn "${TARGET_USER}")"
TARGET_HOME="$(eval echo "~${TARGET_USER}")"

ARCH="amd64"
OS="linux"
GO_TARBALL="go${GO_VERSION}.${OS}-${ARCH}.tar.gz"
GO_URL="https://go.dev/dl/${GO_TARBALL}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "#### installing Go ${GO_VERSION}"

curl -fsSL -o "${TMP_DIR}/${GO_TARBALL}" "${GO_URL}"

rm -rf /usr/local/go
tar -C /usr/local -xzf "${TMP_DIR}/${GO_TARBALL}"

# System-wide profile configuration
cat > /etc/profile.d/go.sh <<'EOF'
export GOROOT="/usr/local/go"
export GOPATH="$HOME/go"
export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"
EOF
chmod 644 /etc/profile.d/go.sh

# User-specific .bashrc configuration
BASHRC="${TARGET_HOME}/.bashrc"
grep -qxF 'export GOROOT="/usr/local/go"' "${BASHRC}" || \
  echo 'export GOROOT="/usr/local/go"' >> "${BASHRC}"

grep -qxF 'export GOPATH="$HOME/go"' "${BASHRC}" || \
  echo 'export GOPATH="$HOME/go"' >> "${BASHRC}"

grep -qxF 'export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"' "${BASHRC}" || \
  echo 'export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"' >> "${BASHRC}"

# Ensure Go workspace directories exist with proper ownership
install -d -m 0755 -o "${TARGET_USER}" -g "${TARGET_GROUP}" "${TARGET_HOME}/go"
install -d -m 0755 -o "${TARGET_USER}" -g "${TARGET_GROUP}" "${TARGET_HOME}/go/bin"
install -d -m 0755 -o "${TARGET_USER}" -g "${TARGET_GROUP}" "${TARGET_HOME}/go/src"
install -d -m 0755 -o "${TARGET_USER}" -g "${TARGET_GROUP}" "${TARGET_HOME}/go/pkg"

echo
echo "==== Go Version ===="
/usr/local/go/bin/go version
echo "===================="
