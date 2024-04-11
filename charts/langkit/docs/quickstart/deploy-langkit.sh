#!/usr/bin/env bash

# Setting common bash options
set -o errexit  # Exit on error
set -o nounset  # Treat unset variables as an error
set -o pipefail # Consider errors in a pipeline

# Default values for configuration variables
whylabs_api_key=""
langkit_password=""
registry_username=""
registry_email=""
registry_token=""
chart_version=""
namespace="default"

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
    --registry-email) registry_email="$2"; shift ;;
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

# Set the current Kubernetes context namespace
kubectl config set-context --current --namespace="${namespace}"

if ! kubectl get secret whylabs-api-key &> /dev/null; then
  kubectl create secret generic whylabs-api-key \
    --from-literal=WHYLABS_API_KEY="${whylabs_api_key}"
  echo "whylabs-api-key secret created."
else
  echo "whylabs-api-key secret already exists; skipping creation."
fi

# Verify the secret was created successfully
if [ $? -ne 0 ]; then
  echo "whylabs-api-key secret creation failed; exiting"
  exit 1
fi
  
if ! kubectl get secret langkit-api-secret &> /dev/null; then
  kubectl create secret generic langkit-api-secret \
    --from-literal=CONTAINER_PASSWORD="${langkit_password}"
  echo "langkit-api-secret created."
else
  echo "langkit-api-secret already exists; skipping creation."
fi

# Verify the secret was created successfully
if [ $? -ne 0 ]; then
  echo "langkit-api-secret secret creation failed; exiting"
  exit 1
fi

# Use --registry-email if provided, otherwise default to <username>@noreply.gitlab.com
if [ -z "$registry_email" ]; then
  registry_email="${registry_username}@noreply.gitlab.com"
fi

if ! kubectl get secret langkit-gitlab-registry-secret &> /dev/null; then
  kubectl create secret docker-registry langkit-gitlab-registry-secret \
    --docker-server="registry.gitlab.com" \
    --docker-username="${registry_username}" \
    --docker-password="${registry_token}" \
    --docker-email="${registry_email}"
  echo "langkit-gitlab-registry-secret created."
else
  echo "langkit-gitlab-registry-secret already exists; skipping creation."
fi

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
  --set "service.type=LoadBalancer" \
  --set "service.annotations.service\.beta\.kubernetes\.io/aws-load-balancer-type=external" \
  --set "service.annotations.service\.beta\.kubernetes\.io/aws-load-balancer-type=nlb" \
  --set "service.annotations.service\.beta\.kubernetes\.io/aws-load-balancer-scheme=internet-facing" \
  langkit "langkit-${chart_version}.tgz"

# Check if Helm chart installation was successful
if [ $? -ne 0 ]; then
  echo "Helm chart installation failed; exiting"
  exit 1
fi

for (( i=1; i<=15; i++ )); do
  echo "Attempt $i of 15: Checking for load balancer hostname..."
  HOSTNAME=$(kubectl get svc langkit -o json | jq -r '.status.loadBalancer.ingress[0].hostname')

  if [ -n "$HOSTNAME" ]; then
    echo "Langkit deployed successfully. Access the service at: http://${hostname}"
    exit 0
  else
    echo "Load balancer hostname not available yet. Retrying in 10 seconds..."
    sleep 10
  fi
done

echo "Max attempts reached. Load balancer hostname not found."
exit 1
