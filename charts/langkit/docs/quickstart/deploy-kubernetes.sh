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

export AWS_REGION="${aws_region}"

# Create a configuration file for eksctl
cat <<EOF > cluster.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: "${cluster_name}"
  region: "${aws_region}"

iam:
  withOIDC: true

addons:
  - name: vpc-cni
    version: latest
    attachPolicyARNs:
      - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
  - name: coredns
    version: latest
  - name: kube-proxy
    version: latest

managedNodeGroups:
  - name: default
    amiFamily: Bottlerocket
    spot: true
    instanceTypes: ["c7i.2xlarge", "c6i.2xlarge", "c5.2xlarge"]
    desiredCapacity: 1
    minSize: 1
    maxSize: 4
EOF

# Check if the configuration file exists
if [ ! -f cluster.yaml ]; then
	echo "Configuration file not found; exiting"
	exit 1
fi

# Create the cluster from the configuration file
eksctl create cluster -f cluster.yaml

# Configure and install the AWS Load Balancer Controller
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.1/docs/install/iam_policy.json

policyName="AWSLoadBalancerControllerIAMPolicy"
existingPolicyArn=$(aws iam list-policies --query 'Policies[?PolicyName==`'"${policyName}"'`].Arn' --output text)

if [ -z "$existingPolicyArn" ]; then
  echo "Policy does not exist. Creating new IAM policy: $policyName"
  albPolicyArn=$(aws iam create-policy \
    --policy-name "${policyName}" \
    --policy-document file://iam_policy.json | jq -r '.Policy.Arn')
else
  echo "Policy already exists. Using existing IAM policy ARN: $existingPolicyArn"
  albPolicyArn=$existingPolicyArn
fi

# Create the IAM service account with the policy
eksctl create iamserviceaccount \
  --cluster="${cluster_name}" \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn="${albPolicyArn}" \
  --approve

helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  --set clusterName="${cluster_name}" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
