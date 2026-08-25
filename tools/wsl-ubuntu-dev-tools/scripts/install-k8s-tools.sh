#!/usr/bin/env bash

set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure K9S_VERSION is defined here
source "${SCRIPT_DIR}/versions.sh"

export DEBIAN_FRONTEND=noninteractive

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

ARCH="amd64"
INSTALL_DIR="/usr/local/bin"

# install kind
echo "installing kind ${KIND_VERSION}"
curl -fsSL -o "${TMP_DIR}/kind" \
  "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${ARCH}"
install -o root -g root -m 0755 "${TMP_DIR}/kind" "${INSTALL_DIR}/kind"

# install kubectl
echo "installing kubectl ${KUBECTL_VERSION}"
curl -fsSL -o "${TMP_DIR}/kubectl" \
  "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"
curl -fsSL -o "${TMP_DIR}/kubectl.sha256" \
  "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl.sha256"
echo "$(<"${TMP_DIR}/kubectl.sha256")  ${TMP_DIR}/kubectl" | sha256sum --check
install -o root -g root -m 0755 "${TMP_DIR}/kubectl" "${INSTALL_DIR}/kubectl"

# install helm
echo "installing helm ${HELM_VERSION}"
HELM_TARBALL="helm-${HELM_VERSION}-linux-${ARCH}.tar.gz"
curl -fsSL -o "${TMP_DIR}/${HELM_TARBALL}" \
  "https://get.helm.sh/${HELM_TARBALL}"
tar -C "${TMP_DIR}" -xzf "${TMP_DIR}/${HELM_TARBALL}"
install -o root -g root -m 0755 \
  "${TMP_DIR}/linux-${ARCH}/helm" \
  "${INSTALL_DIR}/helm"

# install k9s: https://github.com/derailed/k9s
echo "installing k9s ${K9S_VERSION}"
K9S_TARBALL="k9s_Linux_amd64.tar.gz"
curl -fsSL -o "${TMP_DIR}/${K9S_TARBALL}" \
  "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/${K9S_TARBALL}"
tar -C "${TMP_DIR}" -xzf "${TMP_DIR}/${K9S_TARBALL}"
install -o root -g root -m 0755 "${TMP_DIR}/k9s" "${INSTALL_DIR}/k9s"

echo "verifying installed versions"
kind --version
kubectl version --client=true
helm version
k9s version
