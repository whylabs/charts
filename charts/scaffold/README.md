# <CHARTNAME>

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.20-dev2](https://img.shields.io/badge/AppVersion-1.0.20--dev2-informational?style=flat-square)

A Helm chart for WhyLabs <CHARTNAME>

## Installing the Chart

```shell
# Downloads a .tgz file to the working directory or --destination path
helm pull \
  oci://ghcr.io/whylabs/<CHARTNAME> \
  --version 0.2.0

helm diff upgrade \
  --allow-unreleased \
  --namespace <target-namespace> \
  `# Specify the .tgz file as the chart` \
  <CHARTNAME>
  <CHARTNAME>-0.2.0.tgz
```

After you've installed the repo you can install the chart.

```shell
helm upgrade --install \
  --create-namespace \
  --namespace <target-namespace> \
  <CHARTNAME>
  <CHARTNAME>-0.2.0.tgz
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
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":70}` | [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) configuration for the `<CHARTNAME>` container. |
| commonLabels | object | `{}` | Labels to add to all chart resources. |
| env | object | `{}` | [Environment variables](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/) for the `<CHARTNAME>` container. |
| extraVolumeMounts | list | `[]` | Extra [volume mounts](https://kubernetes.io/docs/concepts/storage/volumes/) for the `<CHARTNAME>` container. |
| extraVolumes | list | `[]` | Extra [volumes](https://kubernetes.io/docs/concepts/storage/volumes/) for the `Pod`. |
| fullnameOverride | string | `""` | Override the full name of the chart. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the `<CHARTNAME>` container. |
| image.repository | string | `"registry.gitlab.com/whylabs/langkit-container"` | Image repository for the `<CHARTNAME>` container. |
| image.tag | string | `""` | Image tag for the `<CHARTNAME>` container, this will default to `.Chart.AppVersion` if not set. |
| imagePullSecrets[0] | list | `{"name":""}` | Image pull secrets for the `<CHARTNAME>` container. Defaults to `whylabs-{{ .Release.Name }}-registry-credentials`. |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}],"tls":[]}` | [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) configuration for the `<CHARTNAME>` container. |
| livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/health","port":8000},"initialDelaySeconds":30,"periodSeconds":30}` | [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) configuration for the `<CHARTNAME>` container. |
| nameOverride | string | `""` | Override the name of the chart. |
| nodeSelector | object | `{}` | Node labels to match for `Pod` [scheduling](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/). |
| podAnnotations | object | `{}` | Annotations to add to the `Pod`. |
| podLabels | object | `{}` | Labels to add to the `Pod`. |
| podSecurityContext | object | `{"runAsNonRoot":true}` | [Pod security context](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#podsecuritycontext-v1-core), this supports full customisation. |
| readinessProbe | object | `{"failureThreshold":10,"httpGet":{"path":"/health","port":8000},"initialDelaySeconds":30,"periodSeconds":30}` | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) configuration for the `<CHARTNAME>` container. |
| replicaCount | int | `4` | Number of replicas for the service. |
| resources | object | `{"limits":{"cpu":"4","ephemeral-storage":"250Mi","memory":"4Gi"},"requests":{"cpu":"4","ephemeral-storage":"250Mi","memory":"4Gi"}}` | [Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) for the `<CHARTNAME>` container. |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":1000}` | [Security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container) for the `<CHARTNAME>` container. |
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