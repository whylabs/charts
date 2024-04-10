#!/usr/bin/env bash

# Setting common bash options
set -o errexit  # Exit on error
set -o nounset  # Treat unset variables as an error
set -o pipefail # Consider errors in a pipeline

# Default values for configuration variables
whylabs_api_key=""
langkit_password=""
registry_username=""
registry_token=""
chart_version=""

# Function to print usage
usage() {
  echo "Usage: $0 [--whylabs-api-key <key>] [--langkit-password <password>] [--registry-username <username>]"
  echo "          [--chart-version <version>] [--registry-token <token>]"
  exit 1
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --whylabs-api-key) whylabs_api_key="$2"; shift ;;
    --langkit-password) langkit_password="$2"; shift ;;
    --registry-username) registry_username="$2"; shift ;;
    --registry-token) registry_token="$2"; shift ;;
    --chart-version) chart_version="$2"; shift ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Check mandatory parameters
if [ -z "$whylabs_api_key" ] || [ -z "$langkit_password" ] || [ -z "$registry_username" ] || [ -z "$registry_token" ] || [ -z "$chart_version" ]; then
  echo "Error: Missing required parameters."
  usage
fi

# Create Kubernetes secrets
kubectl create secret generic whylabs-api-key \
  --namespace=langkit \
  --from-literal=WHYLABS_API_KEY="${whylabs_api_key}"

# Verify the secret was created successfully
if [ $? -ne 0 ]; then
  echo "whylabs-api-key secret creation failed; exiting"
  exit 1
fi
  
kubectl create secret generic langkit-api-secret \
  --namespace=langkit \
  --from-literal=CONTAINER_PASSWORD="${langkit_password}"

# Verify the secret was created successfully
if [ $? -ne 0 ]; then
  echo "langkit-api-secret secret creation failed; exiting"
  exit 1
fi
  
kubectl create secret docker-registry langkit-gitlab-registry-secret \
  --docker-server="registry.gitlab.com" \
  --docker-username="${registry_username}" \
  --docker-password="${registry_token}" \
  --docker-email="${registry_username}@noreply.gitlab.com" \
  --namespace=langkit

# Verify the secret was created successfully
if [ $? -ne 0 ]; then
  echo "langkit-gitlab-registry-secret secret creation failed; exiting"
  exit 1
fi

# Download the langkit Helm chart
helm pull \
  oci://ghcr.io/whylabs/langkit \
  --version "${chart_version}"

# Check if helm pull was successful
if [ $? -ne 0 ]; then
  echo "Helm chart download failed; exiting"
  exit 1
fi

# Verify the Helm chart file exists at the expected path
if [ ! -f "langkit-${chart_version}.tgz" ]; then
  echo "Helm chart not found; exiting"
  exit 1
fi

# Install the langkit Helm chart
helm upgrade --install \
  --namespace default \
  langkit "langkit-${chart_version}.tgz"

# Check if Helm chart installation was successful
if [ $? -ne 0 ]; then
  echo "Helm chart installation failed; exiting"
  exit 1
fi
