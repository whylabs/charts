# guardrails

![Version: 0.2.1](https://img.shields.io/badge/Version-0.2.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.23](https://img.shields.io/badge/AppVersion-1.0.23-informational?style=flat-square)

A Helm chart for WhyLabs Guardrails

## Prerequisites

### API Key

Create a [WhyLabs API Key](https://docs.whylabs.ai/docs/whylabs-api/#creating-an-api-token)
that will be used when creating the required Kubernetes secrets to authenticate
with the WhyLabs API.

### Secrets

Use the following `kubectl` commands to create the required Kubernetes
`Secrets`. These secrets must exist prior to installing the Helm chart.

```shell
# API that was created above
whylabs_api_key=""
# Arbitrary value that will be required to make requests to the containers
container_password=""
# Change this to the desired namespace
target_namespace="default"
# Helm release name (See installation for release_name usage)
release_name=""

kubectl create secret generic "whylabs-${release_name}-api-key" \
  --namespace "${target_namespace}" \
  --from-literal=WHYLABS_API_KEY="${whylabs_api_key}"

kubectl create secret generic "whylabs-${release_name}-api-secret" \
  --namespace "${target_namespace}" \
  --from-literal=CONTAINER_PASSWORD="${container_password}"

kubectl create secret docker-registry "whylabs-${release_name}-registry-credentials" \
  --namespace "${target_namespace}" \
  --docker-server="registry.gitlab.com" \
  --docker-username="<whylabs-provided-username>" \
  --docker-password="<whylabs-provided-token>" \
  --docker-email="<whylabs-provided-email>"
```

## Installation & Upgrades

> :warning: To expose guardrails to callers outside of your K8s cluster you will
need an Ingress Controller such as
[NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/), a
Gateway Controller such as [Ambassador](https://www.getambassador.io/), a
Service Mesh such as [Istio](https://istio.io/), or a Load Balancer Controller
such as [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller).
The installation and configuration of the aforementioned controllers are outside
the scope of this document. However, for a quickstart guide to expose Guardrails
to the public internet via AWS LBC, see the
[Exposing Guardrails Outside Kubernetes](#exposing-guardrails-outside-kubernetes)
section.

### How to Use WhyLabs Helm Repository

> :warning: WhyLab's Helm charts are hosted on GitHub Container Registry (GHCR),
> an OCI-compliant storage solution. GHCR aligns with industry standards for
> container artifact storage and has a slightly different API to be aware of.
> Use the `helm pull` command to download the a `.tgz` archive of the chart.
> Reference the `.tgz` archive as the chart identifier when installing.

```shell
# Specify the namespace to install the chart into
target_namespace=""
# Helm release name
release_name=""

# The following command will download a guardrails-${chart_version}.tgz file to
# the working directory or --destination path
helm pull \
  oci://ghcr.io/whylabs/guardrails \
  --version 0.2.1

# Requires the helm-diff plugin to be installed:
# helm plugin install https://github.com/databus23/helm-diff
helm diff upgrade \
  --allow-unreleased \
  --namespace "${target_namespace}" \
  "${release_name}" guardrails-0.2.1.tgz
```

After you've installed the repo you can install the chart.

```shell
helm upgrade --install \
  --create-namespace \
  --namespace "${target_namespace}" \
  "${release_name}" guardrails-0.2.1.tgz
```

## Exposing Guardrails Outside Kubernetes

This section serves as a quickstart guide to install AWS LBC and configure the
Helm chart to expose Guardrails outside of your Kubernetes cluster via an
internal NLB.

1. [Install AWS LBC](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/installation/)
1. Modify the `values.yaml` file:
    1. Change `service.type` to `LoadBalancer`
    1. Set `service.annotations` to the appropriate annotations for your desired
  load balancer configuration.

The following `values.yaml` service configuration will create a Network
Load Balancer (NLB) that resolves to private IP addresses and registers the Pod
IPs as load balancer targets:

```yaml
service:
  annotations:
    # Explicitly delegate LB controll to AWS Load Balancer Controller
    service.beta.kubernetes.io/aws-load-balancer-type: "external"
    # Create an NLB that resolves to public IP addresses
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internal"
    # Register the Pods IPs as load balancer targets
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
    # Use TCP protocol for traffic between NLB and Pods
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "tcp"
  # Must be of type LoadBalancer
  type: LoadBalancer
```

## Horizontal Pod Autoscaling (HPA)

The Horizontal Pod Autoscaler automatically scales the number of pods in a
replication controller, deployment, replica set or stateful set based on
observed CPU utilization (or, with custom metrics support, on some other
application-provided metrics). The Horizontal Pod Autoscaler uses the following
formula to calculate the desired number of pods:

```text
Desired Replicas = [ (Current Utilization / Target Utilization) * Current Replicas ]
```

For example, if an HPA is configured with a target CPU utilization of 50%, there
are currently 3 pods, and the current average CPU utilization is 90%, the number
of replicas will be scaled to 6:

```text
Desired Replicas = ⌈ (90% / 50%) * 3 ⌉
                 = ⌈ 1.8 * 3 ⌉
                 = ⌈ 5.4 ⌉
                 = 6
```

HPA uses the same formula for both increasing and decreasing the number of pods.
Horizontal pod scaling is disabled by default. To enable it, set the
`hpa.enabled` key to `true`. The pods QoS class will impact HPA behavior as a
deployment that is allowed to burst CPU usage will cause more aggressive HPA
scaling than a deployment with a `Guaranteed` QoS that does not go above 100%
utilization.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity settings for `Pod` [scheduling](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/). If an explicit label selector is not provided for pod affinity or pod anti-affinity one will be created from the pod selector labels. |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":70}` | [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) configuration for the `guardrails` container. |
| commonLabels | object | `{}` | Labels to add to all chart resources. |
| env | object | `{}` | [Environment variables](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/) for the `guardrails` container. |
| extraVolumeMounts | list | `[]` | Extra [volume mounts](https://kubernetes.io/docs/concepts/storage/volumes/) for the `guardrails` container. |
| extraVolumes | list | `[]` | Extra [volumes](https://kubernetes.io/docs/concepts/storage/volumes/) for the `Pod`. |
| fullnameOverride | string | `""` | Override the full name of the chart. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the `guardrails` container. |
| image.repository | string | `"registry.gitlab.com/whylabs/langkit-container"` | Image repository for the `guardrails` container. |
| image.tag | string | `""` | Image tag for the `guardrails` container, this will default to `.Chart.AppVersion` if not set. |
| imagePullSecrets[0] | list | `{"name":""}` | Image pull secrets for the `guardrails` container. Defaults to `whylabs-{{ .Release.Name }}-registry-credentials` if `name: ""`. To exclude The ImagePullSecret entirely, set `imagePullSecrets: []` and comment out the list items. |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}],"tls":[]}` | [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) configuration for the `guardrails` container. |
| livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/health","port":8000},"initialDelaySeconds":30,"periodSeconds":30}` | [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) configuration for the `guardrails` container. |
| nameOverride | string | `""` | Override the name of the chart. |
| nodeSelector | object | `{}` | Node labels to match for `Pod` [scheduling](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/). |
| podAnnotations | object | `{}` | Annotations to add to the `Pod`. |
| podLabels | object | `{}` | Labels to add to the `Pod`. |
| podSecurityContext | object | `{"runAsNonRoot":true}` | [Pod security context](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#podsecuritycontext-v1-core), this supports full customisation. |
| readinessProbe | object | `{"failureThreshold":10,"httpGet":{"path":"/health","port":8000},"initialDelaySeconds":30,"periodSeconds":30}` | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) configuration for the `guardrails` container. |
| replicaCount | int | `4` | Number of replicas for the service. |
| resources | object | `{"limits":{"cpu":"4","ephemeral-storage":"250Mi","memory":"4Gi"},"requests":{"cpu":"4","ephemeral-storage":"250Mi","memory":"4Gi"}}` | [Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) for the `guardrails` container. |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":1000}` | [Security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container) for the `guardrails` container. |
| service.annotations | object | `{}` | Service annotations. |
| service.port | int | `80` | Service HTTP port. |
| service.targetPort | int | `8000` | The port on which the application container is listening. |
| service.type | string | `"ClusterIP"` | Service Type, i.e. ClusterIp, LoadBalancer, etc. |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account. |
| serviceAccount.automount | bool | `true` | Set this to `false` to [opt out of API credential automounting](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#opt-out-of-api-credential-automounting) for the `ServiceAccount`. |
| serviceAccount.create | bool | `true` | If `true`, create a new `ServiceAccount`. |
| serviceAccount.labels | object | `{}` | Labels to add to the service account. |
| serviceAccount.name | string | `""` | If this is set and `serviceAccount.create` is `true` this will be used for the created `ServiceAccount` name, if set and `serviceAccount.create` is `false` then this will define an existing `ServiceAccount` to use. |
| tolerations | list | `[]` | Node taints which will be tolerated for `Pod` [scheduling](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/). |

----------------------------------------------

Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs/).