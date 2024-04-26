# guardrails

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for Kubernetes

## Installing the Chart

```shell
# Downloads a .tgz file to the working directory or --destination path
helm pull \
  oci://ghcr.io/whylabs/guardrails \
  --version 0.1.0

helm diff upgrade \
  --allow-unreleased \
  --namespace <target-namespace> \
  `# Specify the .tgz file as the chart` \
  guardrails guardrails-0.1.0.tgz
```

After you've installed the repo you can install the chart.

```shell
helm upgrade --install \
  --create-namespace \
  --namespace <target-namespace> \
  guardrails guardrails-0.1.0.tgz
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity settings for `Pod` [scheduling](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/). If an explicit label selector is not provided for pod affinity or pod anti-affinity one will be created from the pod selector labels. |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| commonLabels | object | `{}` | Labels to add to all chart resources. |
| env | object | `{}` | [Environment variables](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/) for the `guardrails` container. |
| extraVolumeMounts | list | `[]` | Extra [volume mounts](https://kubernetes.io/docs/concepts/storage/volumes/) for the `guardrails` container. |
| extraVolumes | list | `[]` | Extra [volumes](https://kubernetes.io/docs/concepts/storage/volumes/) for the `Pod`. |
| fullnameOverride | string | `""` | Override the full name of the chart. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the `guardrails` container. |
| image.repository | string | `"registry.gitlab.com/whylabs/whylogs-container"` | Image repository for the `guardrails` container. |
| image.tag | string | `"1.0.14"` | Image tag for the `guardrails` container, this will default to `.Chart.AppVersion` if not set. |
| imagePullSecrets[0] | list | `{"name":""}` | Image pull secrets for the `guardrails` container. Defaults to `whylabs-{{ .Release.Name }}-registry-credentials`. |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}],"tls":[]}` | [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) configuration for the `guardrails` container. |
| livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/health","port":8000},"initialDelaySeconds":30,"periodSeconds":30}` | [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) configuration for the `guardrails` container. |
| nameOverride | string | `""` | Override the name of the chart. |
| nodeSelector | object | `{}` | Node labels to match for `Pod` [scheduling](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/). |
| podAnnotations | object | `{}` | Annotations to add to the `Pod`. |
| podLabels | object | `{}` | Labels to add to the `Pod`. |
| podSecurityContext | object | `{"runAsNonRoot":true}` | [Pod security context](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/#podsecuritycontext-v1-core), this supports full customisation. |
| readinessProbe | object | `{"failureThreshold":10,"httpGet":{"path":"/health","port":8000},"initialDelaySeconds":30,"periodSeconds":30}` | [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) configuration for the `guardrails` container. |
| replicaCount | int | `2` |  |
| resources | object | `{"limits":{"cpu":"4","memory":"4Gi"},"requests":{"cpu":"4","memory":"4Gi"}}` | [Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) for the `guardrails` container. |
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