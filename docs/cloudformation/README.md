# Deployment Documentation for WhyLabs Containerized Application

This document provides a comprehensive guide for deploying the WhyLabs
containerized application using an AWS CloudFormation template. The template is
designed to facilitate an easy and efficient setup for users who may not be
familiar with cloud infrastructure.

## Prerequisites

Before you begin the deployment, ensure you have the following prerequisites:

1. **AWS Account**: Access to an AWS account with permissions to create and
manage AWS CloudFormation stacks and associated resources such as EC2 instances,
VPCs, subnets, and security groups.

1. **API Keys and Credentials**:

  - **WhyLabs API Key and Container Password**: These are essential for the
  application to function. If you do not have these credentials, please contact
  WhyLabs to obtain them.

  - **Docker Registry Credentials**: Username and password for the Docker
  registry where the WhyLabs container image is hosted. These credentials are
  necessary for your EC2 instances to pull the container image.

    ```bash
    docker login registry.gitlab.com -u "${username}" -p "${password}"
    ```

## Deployment Steps

### Step 1: Upload the CloudFormation Template

Log in to your AWS account and navigate to the AWS CloudFormation service.
Select "Create stack" and upload the provided CloudFormation template. AWS
CloudFormation provides a user-friendly interface to input all required
parameters.

### Step 2: Input Parameters

You will be prompted to enter values for various parameters. Here's a brief
explanation of key parameters:

- **API Keys and Credentials**: Enter your WhyLabs API key, container password,
and Docker registry credentials. These fields are secured (NoEcho: true) to
ensure sensitive information is not displayed in the console.

- **VPC and Subnet Configuration**: By default, the template will create a new
VPC and subnets. However, you can provide an existing VPC and subnet IDs if you
prefer to use existing networking resources.

- **Ingress and Egress Configuration**: Define CIDR blocks for ingress and
egress to control network traffic. Ingress CIDR determines who can access your
application, while Egress CIDR controls where your instances can send traffic.

### Step 3: Deploy the Stack

After filling in the parameters, proceed to deploy the stack. AWS CloudFormation
will handle the resource creation and configuration as defined in the template.

### Step 4: Accessing the Application

Once the stack deployment is complete, navigate to the "Outputs" section of your
CloudFormation stack. Here you will find the URL endpoint for your WhyLabs
application. This URL is the entry point to your deployed service.

## Resource Description and Architecture

By default, the CloudFormation template creates the following resources:

- **Elastic Load Balancing (ELB)**: Distributes incoming application traffic
across multiple targets, such as EC2 instances.

- **Auto Scaling Group**: Ensures that you have the correct number of Amazon EC2
instances available to handle the load for your application.

- **VPC, Subnets, and Routing**: Network configuration that provides isolation
and routing for your application instances.

- **Security Groups**: Acts as a virtual firewall to control inbound and
outbound traffic.

## Security Considerations

- **Security Groups**: Configured to allow inbound traffic on specified ports
only from trusted sources (controlled by the Ingress CIDR block).

- **IAM Role**: Ensure minimal access rights that are necessary for the
resources to operate.

## Common Scenarios and Overrides

- **Using an Existing VPC**: If you prefer to use an existing VPC, provide the
VPC ID and IDs for two public subnets and one private subnet. This setup is
critical for integrating the application into your existing AWS environment.

- **Custom CIDR Blocks**: You can override the default VPC CIDR block for custom
network planning. Adjusting the Ingress CIDR block can restrict access to your
application, ensuring that only traffic from specific networks can access the
load balancer.

- **Egress CIDR**: Controls the outbound traffic from your instances. Configure
this to restrict outbound access to the internet or other services within your
network.

This guide aims to equip you with the necessary information to successfully
deploy and manage your WhyLabs application using AWS CloudFormation. For any
additional questions or assistance, please reach out to WhyLabs support.
