# guardrails

![Version: 0.5.2](https://img.shields.io/badge/Version-0.5.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.2.2](https://img.shields.io/badge/AppVersion-2.2.2-informational?style=flat-square)

A Helm chart for WhyLabs Guardrails

- [Prerequisites](#prerequisites)
- [Configuring WhyLabs credentials](#whylabs-credentials)
- [Helm Chart Installation & Upgrades](#installation--upgrades)
- [Exposing Guardrails Outside Kubernetes](#exposing-guardrails-outside-kubernetes)
- [Horizontal Pod Autoscaling (HPA)](#horizontal-pod-autoscaling-hpa)

## Prerequisites

- [Create and configure WhyLabs credentials](#whylabs-credentials)

## WhyLabs credentials

- [WhyLabs API Key](#whylabs-api-key)
- [WhyLabs Container Password](#whylabs-container-password)

### WhyLabs API Key

1. Create a [WhyLabs API Key](https://docs.whylabs.ai/docs/whylabs-api/#creating-an-api-token)

2. Store the API key in one of the following locations:

  - [Kubernetes Secret](#kubernetes-secret-default)
  - [Mounted Volume](#mounted-volume)

#### Kubernetes Secret (Default)

```shell
# WhyLabs API key
whylabs_api_key=""

# Change this to the desired namespace
target_namespace="default"

# The `WHYLABS_API_KEY` key is used as the env variable name within the `Pod`
kubectl create secret generic "whylabs-guardrails-api-key" \
  --namespace "${target_namespace}" \
  --from-literal=WHYLABS_API_KEY="${whylabs_api_key}"
```

#### Mounted Volume

Alternatively, any file mounted to `/var/run/secrets/whylabs.ai/env` will be automatically picked up by the container and used as an environment variable. The environment variable name will be the filename, and the file contents will be the value, e.g.:

```shell
$ tree /var/run/secrets/whylabs.ai/env

/var/run/secrets/whylabs.ai/env
├── whylabs_api_key
├── container_password
└── any_other_env_vars

$ cat /var/run/secrets/whylabs.ai/env/whylabs_api_key

MyS3cr3tWhyL@b5@piK3y
```

Declare and mount the volumes by overriding `extraVolumes` and `extraVolumeMounts` in the `values.yaml` file. The following example assumes the use of the [AWS Secrets Store CSI Driver](https://github.com/aws/secrets-store-csi-driver-provider-aws), but the concept is the same for any other method of mounting files into the container.

```yaml
extraVolumeMounts:
  - name: whylabs-secret-provider
    mountPath: /var/run/secrets/whylabs.ai/env
    readOnly: true

extraVolumes:
  - name: whylabs-secret-provider
    csi:
      driver: secrets-store.csi.k8s.io
      readOnly: true
      volumeAttributes:
        secretProviderClass: "your-whylabs-secret-provider-name"
```

### WhyLabs Container Password

The container password is an arbitrary value that must be included with every guardrails container request (required by default). To disable the container password, set the `DISABLE_CONTAINER_PASSWORD` environment variable to `True`.

To store the container password in a Kubernetes Secret, run the following command:

```shell
# Arbitrary value that will be required to make requests to the containers
container_password=""

# Change this to the desired namespace
target_namespace="default"

# The `CONTAINER_PASSWORD` key is used as the env variable name within the `Pod`
kubectl create secret generic "whylabs-guardrails-api-secret" \
  --namespace "${target_namespace}" \
  --from-literal=CONTAINER_PASSWORD="${container_password}"
```

Alternatively, the container password can be provided as a [mounted volume](#mounted-volume) as described in the [WhyLabs API Key](#whylabs-api-key) section.

## Installation & Upgrades

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
  --version 0.5.2

# Requires the helm-diff plugin to be installed:
# helm plugin install https://github.com/databus23/helm-diff
helm diff upgrade \
  --allow-unreleased \
  --namespace "${target_namespace}" \
  "${release_name}" guardrails-0.5.2.tgz
```

After you've installed the repo you can install the chart.

```shell
helm upgrade --install \
  --create-namespace \
  --namespace "${target_namespace}" \
  "${release_name}" guardrails-0.5.2.tgz
```

## Exposing Guardrails Outside Kubernetes

> :warning: To expose guardrails to callers outside of your K8s cluster you will
need an Ingress Controller such as
[NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/), a
Gateway Controller such as [Ambassador](https://www.getambassador.io/), a
Service Mesh such as [Istio](https://istio.io/), or a Load Balancer Controller
such as [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller).
The installation and configuration of the aforementioned controllers are outside
the scope of this document. However, for a quickstart guide to expose Guardrails
to the public internet via AWS LBC, see the following section.

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
observed CPU utilization (among other metrics that are not in scope for this document). The Horizontal Pod Autoscaler uses the following default formula to calculate the desired number of pods:

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
`autoscaling.enabled` to `true`.

### Scaling Behavior configuration

When using Horizontal Pod Autoscalers (HPAs) with default configurations users may encounter the following issues:

- Frequent and rapid scaling operations
- Resource contention caused by aggressive scaling
- Startup time delays and queue buildup
- General behavior that appears as though the HPA is not working

The following Horizontal Pod Autoscaler configuration is intended to provide a
reasonable starting point. :warning: Each deployment will have unique
characteristics that will require tuning scaling behavior based on factors
such as node size and type; starting replica count; request load; traffic
patterns, etc. The following concepts, referencing the example configuration
below, provide a framework for understanding how the HPA behavior configuration
works and how to tune it for optimal scaling.

- The `scaleUp` and `scaleDown` policies limit the number of pods added or removed in a single evaluation period.
- The `stabilizationWindowSeconds` parameter ensures scaling decisions are based on an averaged utilization over 300 seconds, smoothing out temporary spikes or dips in resource usage.
- The 180-second `periodSeconds` ensures scaling operations are spaced out, allowing the system to stabilize before further scale operations occur.

```yaml
autoscaling:
  # Enable or disable HPA (Horizontal Pod Autoscaler).
  enabled: false

  # The lower limit for the number of replicas to scale down
  minReplicas: 1

  # The upper limit for the number of replicas to scale up
  maxReplicas: 100

  # The specifications to use for calculating the desired replica count
  targetCPUUtilizationPercentage: 70

  # The behavior configuration for scaling up/down.
  behavior:

    # This configuration provides two policies: a policy that scales the number
    # of replicas by a fixed amount (4 pods), and a policy that scales the
    # number of replicas by a percentage (50%). Setting `selectPolicy` to `Min`
    # will select the scaling policy that creates the fewest number of replicas.
    # The `stabilizationWindowSeconds` parameter smooths out temporary
    # fluctuations in CPU utilization by evaluating recommendations over a
    # 300-second window.
    scaleUp:
      policies:
        - type: Pods
          value: 4
          periodSeconds: 180
        - type: Percent
          value: 50
          periodSeconds: 180
      selectPolicy: Min
      stabilizationWindowSeconds: 300

    scaleDown:
      policies:
        - type: Pods
          value: 4
          periodSeconds: 180
        - type: Percent
          value: 30
          periodSeconds: 180
      selectPolicy: Max
      stabilizationWindowSeconds: 300
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | [Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) settings for `Pod`. |
| autoscaling.behavior.scaleUp.policies | list | `[]` | A list of potential [scaling polices](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#scaling-policies) which can be used during scaling |
| autoscaling.behavior.scaleUp.selectPolicy | string | `"Min"` | Selects which scaling policy to use; selects the policy that performs the `Max` or `Min` scaling. Also applies to `scaleDown` behavior. |
| autoscaling.behavior.scaleUp.stabilizationWindowSeconds | int | `300` | How many seconds the HPA looks back to determine if a policy is being met; uses the highest recommendation within the stabilization window. Also applies to `scaleDown` behavior. |
| autoscaling.enabled | bool | `false` | Enable or disable HPA (Horizontal Pod Autoscaler). |
| autoscaling.maxReplicas | int | `100` | The upper limit for the number of replicas to which the autoscaler can scale up |
| autoscaling.minReplicas | int | 1 | The lower limit for the number of replicas to which the autoscaler can scale down |
| autoscaling.targetCPUUtilizationPercentage | int | 80 | The specifications for which to use to calculate the desired replica count |
| cache.annotations | object | `{}` | Annotations for the cache. |
| cache.duration | string | `"1m"` | Duration for cache validity. |
| cache.enable | bool | `true` | Enable or disable caching. |
| cache.endpoint | string | `"api.whylabsapp.com"` | Endpoint for the cache service. |
| cache.labels | object | `{}` | Labels for the cache. |
| cache.replicaCount | int | `1` | Number of replicas for the cache. |
| commonLabels | object | `{}` | Labels to add to all chart resources. |
| env | object | `{"CONFIG_SYNC_INTERVAL":"1","TENANCY_MODE":"{{ .Values.tenancyMode | default \"SINGLE\" }}","WHYLABS_API_CACHE_ENDPOINT":"{{ if .Values.cache.enable }}{{ .Release.Name }}-nginx.{{ .Release.Namespace }}.svc.cluster.local{{ else }}{{ end }}"}` | [Environment variables](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/) for the `guardrails` container. **Supports Helm templating syntax**, e.g. you can use `{{ .Release.Name }}` or other templating variables, functions, and conditions within the the value of each environment variable. |
| envFrom | list | `[{"secretRef":{"name":"whylabs-guardrails-api-key","optional":true}},{"secretRef":{"name":"whylabs-guardrails-api-secret","optional":true}}]` | Create environment variables from Kubernetes secrets or config maps. |
| envFrom[0].secretRef.name | string | `"whylabs-guardrails-api-key"` | Name of the Kubernetes secret containing the API key. The secret must be in the same namespace as the release and should be created prior to installing the chart. |
| envFrom[1].secretRef.name | string | `"whylabs-guardrails-api-secret"` | Name of the Kubernetes secret containing the container password, the value used when executing requests against the guardrails container. The secret must be in the same namespace as the release and should be created prior to installing the chart. |
| extraVolumeMounts | list | `[]` | Extra [volume mounts](https://kubernetes.io/docs/concepts/storage/volumes/) for the `guardrails` container. |
| extraVolumes | list | `[]` | Extra [volumes](https://kubernetes.io/docs/concepts/storage/volumes/) for the `Pod`. |
| fullnameOverride | string | `""` | Override the full name of the chart. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the `guardrails` container. |
| image.repository | string | `"registry.gitlab.com/whylabs/langkit-container"` | Image repository for the `guardrails` container. |
| image.tag | string | `"2.2.2"` | Image tag for the `guardrails` container, this will default to `.Chart.AppVersion` if not set. |
| imagePullSecrets | list | `[]` |  |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}],"tls":[]}` | [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) configuration for the `guardrails` container. |
| livenessProbe | object | `{"failureThreshold":5,"httpGet":{"path":"/health","port":8000},"periodSeconds":10}` | [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) configuration for the `guardrails` container. Failed livenessProbes restarts containers |
| nameOverride | string | `""` | Override the name of the chart. |
| nodeSelector | object | `{}` | Node labels to match for `Pod` [scheduling](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/). |
| podAnnotations | object | `{}` | Annotations to add to the `Pod`. |
| podLabels | object | `{}` | Labels to add to the `Pod`. |
| podSecurityContext | object | `{"runAsNonRoot":true}` | [Pod security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod), this supports full customisation. |
| readinessProbe | object | `{"failureThreshold":2,"httpGet":{"path":"/health","port":8000},"periodSeconds":10}` | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) configuration for the `guardrails` container. Failed readinessProbes remove the pod from the service. |
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
| startupProbe | object | `{"failureThreshold":20,"httpGet":{"path":"/health","port":8000},"initialDelaySeconds":20,"periodSeconds":10}` | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) configuration for the `guardrails` container. Liveness and readiness probes are suppressed until the startup probe succeeds. |
| tenancyMode | string | `"SINGLE"` | tenancyMode for the guardrails service. Must be `SINGLE` or `MULTI`. |
| tolerations | list | `[]` | Node taints which will be tolerated for `Pod` [scheduling](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/). |

----------------------------------------------

Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs/).