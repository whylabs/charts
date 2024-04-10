# Fargate Deployment


This guide describes how to set up an EKS cluster using Fargate for deploying
Langkit. The process involves three separate scripts for better organization and
maintainability.

## Prerequisites

- An AWS account with appropriate permissions for EKS and Fargate.
- Git installed on your local machine.

## Steps

1. Clone this repository

    ```shell
    git clone https://github.com/whylabs/charts.git

    (
      cd charts/langkit/docs
      chmod 755 prepare.sh
      chmod 755 deploy-fargate.sh
      chmod 755 deploy-langkit.sh
    )
    ```

1. Install dependencies

    Navigate to the cloned directory and run the following command to install
    `eksctl` and `helm` for managing EKS clusters and Helm charts:

    ```shell
    ./prepare.sh
    ```

1. Create EKS Fargate Cluster

    This script creates an EKS cluster configured to use Fargate for pod
    execution. By default, it creates a cluster named whylabs in the us-west-2
    region:

    ```shell
    ./deploy-fargate.sh \
      --cluster-name whylabs \
      --aws-region us-west-2
    ```

1. Deploy Langkit

    ```shell
    ./deploy-langkit.sh \
      --whylabs_api_key <key> \
      --langkit_password <password> \
      --registry_username <username> \
      --registry_token <token> \
      --chart_version <version>
    ```
