#!/usr/bin/env bash

# Setting common bash options
set -o errexit  # Exit on error
set -o nounset  # Treat unset variables as an error
set -o pipefail # Consider errors in a pipeline

# Determine the architecture
ARCH=$(uname -m)
case $ARCH in
  x86_64)
    ARCH=amd64
    ;;
  aarch64 | arm64)
    ARCH=arm64
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac
PLATFORM=$(uname -s)_$ARCH

# Install eksctl
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"
tar -xzf eksctl_${PLATFORM}.tar.gz -C /tmp && rm eksctl_${PLATFORM}.tar.gz
sudo mv /tmp/eksctl /usr/local/bin

# Validate eksctl installation
if ! command -v eksctl &> /dev/null; then
  echo "eksctl could not be installed"
  exit 1
fi

# Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Validate Helm installation
if ! command -v helm &> /dev/null; then
  echo "Helm could not be installed"
  exit 1
fi

echo "eksctl and helm installation complete"
