#!/usr/bin/env bash

# Setting common bash options
set -o errexit  # Exit on error
set -o nounset  # Treat unset variables as an error
set -o pipefail # Consider errors in a pipeline

# Default values for configuration variables
cluster_name="whylabs"
aws_region="us-west-2"

# Function to print usage
usage() {
  echo "Usage: $0 [--cluster-name <name>] [--aws-region <region>]"
  exit 1
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --cluster-name) cluster_name="$2"; shift ;;
    --aws-region) aws_region="$2"; shift ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Automatically determine the architecture
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

export AWS_REGION="${aws_region}"

# Install eksctl
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
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

# Create a configuration file for eksctl
cat <<EOF > cluster.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: "${cluster_name}"
  region: "${aws_region}"

iam:
  withOIDC: true

fargateProfiles:
  - name: default
    selectors:
      - namespace: default
      - namespace: kube-system
EOF

# Check if the configuration file exists
if [ ! -f cluster.yaml ]; then
	echo "Configuration file not found; exiting"
	exit 1
fi

# Create the cluster from the configuration file
eksctl create cluster -f cluster.yaml
