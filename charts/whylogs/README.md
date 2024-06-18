# whylogs

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.14](https://img.shields.io/badge/AppVersion-1.0.14-informational?style=flat-square)

A Helm chart for WhyLab's WhyLogs

> :mag: See [WhyLogs Documentation](https://docs.whylabs.ai/docs/integrations-whylogs-container/) for more information

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

kubectl create secret generic whylabs-api-key \
  --namespace "${target_namespace}" \
  --from-literal=WHYLABS_API_KEY="${whylabs_api_key}"

kubectl create secret generic whylogs-container-password \
  --namespace "${target_namespace}" \
  --from-literal=CONTAINER_PASSWORD="${container_password}"
```

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

# The following command will download a guardrails-${chart_version}.tgz file to
# the working directory or --destination path
helm pull \
  oci://ghcr.io/whylabs/whylogs \
  --version 0.1.0

# Requires the helm-diff plugin to be installed:
# helm plugin install https://github.com/databus23/helm-diff
helm diff upgrade \
  --allow-unreleased \
  --namespace "${target_namespace}" \
  whylogs whylogs-0.1.0.tgz
```

After you've installed the repo you can install the chart.

```shell
helm upgrade --install \
  --create-namespace \
  --namespace "${namespace}" \
  whylogs "whylogs-0.1.0.tgz"
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| env.DEFAULT_WHYLABS_DATASET_CADENCE | string | `"HOURLY"` |  |
| env.DEFAULT_WHYLABS_UPLOAD_CADENCE | string | `"M"` |  |
| env.DEFAULT_WHYLABS_UPLOAD_INTERVAL | string | `"15"` |  |
| env.DISABLE_CONTAINER_PASSWORD | string | `"False"` |  |
| env.FAIL_STARTUP_WITHOUT_CONFIG | string | `"False"` |  |
| env.WHYLABS_ORG_ID | string | `"org-0"` |  |
| envFromSecrets[0].secretRef.name | string | `"whylabs-api-key"` |  |
| envFromSecrets[1].secretRef.name | string | `"whylogs-container-password"` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"registry.gitlab.com/whylabs/whylogs-container"` |  |
| image.tag | string | `"1.0.14"` |  |
| imagePullSecrets[0].name | string | `"gitlab-container-registry-auth"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.httpGet.path | string | `"/health"` |  |
| livenessProbe.httpGet.port | int | `8000` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `30` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| readinessProbe.failureThreshold | int | `10` |  |
| readinessProbe.httpGet.path | string | `"/health"` |  |
| readinessProbe.httpGet.port | int | `8000` |  |
| readinessProbe.initialDelaySeconds | int | `30` |  |
| readinessProbe.periodSeconds | int | `30` |  |
| replicaCount | int | `1` | Number of replicas for the service. |
| resources | object | `{}` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| service.annotations | object | `{}` |  |
| service.port | int | `80` |  |
| service.targetPort | int | `8000` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automount | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
| volumeMounts[0].mountPath | string | `"/tmp"` |  |
| volumeMounts[0].name | string | `"temp-dir"` |  |
| volumes[0].emptyDir | object | `{}` |  |
| volumes[0].name | string | `"temp-dir"` |  |

----------------------------------------------

Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs/).