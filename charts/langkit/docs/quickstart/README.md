# Quickstart

This guide describes how to set up an EKS cluster for deploying Langkit. The
process involves three separate scripts for better organization and
maintainability.

> :warning: This is not intended to be used in a production environment.

## Prerequisites

- An AWS account with appropriate permissions for creating resources.
- Git installed on your local machine.
- WhyLabs and Langkit credentials.

## Clone This Repository

Clone this repository. The following tutorial will be working with the shell
script files within the directory of this `README`.

```shell
git clone https://github.com/whylabs/charts.git
```

## Environment Setup

- [Recommended] [AWS CloudShell](https://aws.amazon.com/cloudshell/)
- Local terminal

If you're a seasoned pro with AWS and the AWS CLI you can skip ahead to
[using the local terminal](#using-local-terminal).

If you don't already have AWS credentials configured locally, the fastest way to
deploy the Langkit demo cluster is using
[AWS CloudShell](https://aws.amazon.com/cloudshell/), which is a browser-based
shell that already has your credentials configured.

### Using Remote Terminal via [AWS CloudShell](https://aws.amazon.com/cloudshell/)

1. **Login to your AWS Account**

    Be sure to login with a role that has sufficient permissions to create
    Networking, EC2, EKS, and IAM resources.

1. **Verify that you're in the desired region** 

    The region can be selected at the top right corner of the AWS console
    adjacent to your username/email address.

1. **Search for and select/open the `CloudShell` service**

1. **[Upload the provisioning scripts to the `CloudShell` environment](https://docs.aws.amazon.com/cloudshell/latest/userguide/getting-started.html#folder-upload)**

  1. Click the `Actions` drop down menu and choose `Upload File`
  1. Select and upload the `prepare.sh`, `deploy-kubernetes.sh`, and
  `deploy-langkit.sh` files (one at a time).

### Using Local Terminal

Ensure the AWS enviornment is configured correctly. See the official
[getting started with the AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)

### Setting Variables

Set the following variables in your shell environment (local or CloudShell).
Variables with default values may be overridden as desired. Variables without
values **must** be configured.

```shell
# AWS and EKS configuration
cluster_name="whylabs"
aws_region="us-west-2"
namespace="default"

# Langkit configuration
chart_version="0.17.0"
whylabs_api_key=""
langkit_password=""
registry_username=""
registry_token=""
```

## Execute Provisioning Scripts

1. **Ensure scripts have execution permissions set**

    ```shell
    chmod 755 prepare.sh deploy-kubernetes.sh deploy-langkit.sh
    ```

1. **Install dependencies**

    Navigate to the cloned directory and run the following command to install
    `eksctl` and `helm` for managing EKS clusters and Helm charts:

    ```shell
    ./prepare.sh
    ```

1. **Create EKS Cluster**
    
    This script creates an EKS cluster. By default, it creates a cluster named
    `whylabs` in the `us-west-2` region. Change the values to suit your needs.

    > :warning: This process takes ~20 minutes

    ```shell
    ./deploy-kubernetes.sh \
      --cluster-name "${cluster_name}" \
      --aws-region "${aws_region}"
    ```

1. **Deploy Langkit**

    ```shell
    ./deploy-langkit.sh \
      --chart-version "${chart_version}" \
      --whylabs-api_key "${whylabs_api_key}" \
      --langkit-password "${langkit_password}" \
      --registry-username "${registry_username}" \
      --registry-token "${registry_token}"
    ```

1. **Retrieve Langkit URL**

    > :warning: A Network Load Balancer is created by the Langkit service. You
    > can reach the service at the DNS address of the load balancer. It may take
    > a few moments for the load balancer to be provisioned. The following
    > command will return the hostname once it's available. 

    ```shell
    hostname=$(kubectl get service langkit \
      --namespace "${namespace}" \
      -o json | \
        jq -r '.status.loadBalancer.ingress[0].hostname')

    printf "\nLangkit Hostname: http://${hostname}\n\n"
    ```

1. **Verify Deployment**

    You can confirm that the deployment was successful by executing the
    following command. You should see `HTTP/1.1 200 OK` within the response.

    ```shell
    curl -v "http://${hostname}/health"
    ```
