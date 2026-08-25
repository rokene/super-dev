#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "#### installing Azure CLI"

apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor --batch --yes -o /etc/apt/keyrings/microsoft.gpg

chmod a+r /etc/apt/keyrings/microsoft.gpg

# Detect distribution codename and fallback to noble if repo does not exist
AZ_DIST="$(lsb_release -cs)"
REPO_CHECK_URL="https://packages.microsoft.com/repos/azure-cli/dists/${AZ_DIST}/Release"

if ! curl -s --head --fail "${REPO_CHECK_URL}" > /dev/null; then
  echo "Notice: '${AZ_DIST}' repository not found at Microsoft repos. Falling back to 'noble'."
  AZ_DIST="noble"
fi

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ ${AZ_DIST} main" \
  > /etc/apt/sources.list.d/azure-cli.list

apt-get update
apt-get install -y azure-cli

echo
echo "==== Azure CLI Version ===="
az version
echo "==========================="
