# LangKit Helm Chart

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

> :warning: Review the [documentation on using WhyLab's Helm charts](../../README.md#how-to-use-whylabs-helm-repository)

## Prerequisites

NOTE: Change the `--namespace` value if you will be deploying into a namespace other
than `langkit`.


### Credentials
* Create a [WhyLabs API Key](https://docs.whylabs.ai/docs/whylabs-capabilities/#access-token-management)
which must be stored in a `whylabs-api-key` Kubernetes secret, described below.

```shell
kubectl create secret generic whylabs-api-key \
  --namespace=langkit \
  --from-literal=WHYLABS_API_KEY=<whylabs-api-key>
```

* Generate a random value for the `langkit-api-secret` Kubernetes secret, also
described below. **This secret is required to call the container API endpoint**.

```
kubectl create secret generic langkit-api-secret \
  --namespace=langkit \
  --from-literal=CONTAINER_PASSWORD=<langkit-api-secret>
```

### LangKit Configuration

No LangKit configurations are required out of the box. However, for further customizations, 
review the [langkit-container-examples](https://github.com/whylabs/langkit-container-examples)
repository for more details.

## Helm Chart Installation

### Template
Display the full YAML manifests as they will be applied.

```shell
# This will use the "langkit" namespace
helm template --namespace langkit langkit .
```

### Diff
View the difference between the current state and desired state.

```shell
# Requires the helm-diff plugin to be installed:
# helm plugin install https://github.com/databus23/helm-diff
helm diff upgrade \
  --allow-unreleased \
  langkit langkit-0.8.0.tgz
```

### Install/Update
```shell
helm upgrade --install \
  --create-namespace \
  --namespace langkit \
  langkit langkit-0.8.0.tgz
```

### Uninstall
```shell
helm uninstall \
  --namespace langkit \
  langkit langkit-0.8.0.tgz
```

## Development

### Generate Values Table

The following command will output the [Values table](#values) below. Copy and
paste the table into this `README.md` file whenever this chart changes.

```shell
helm-docs --dry-run
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key | string | `"app.kubernetes.io/name"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator | string | `"In"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0] | string | `"langkit"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| containers.env[0].name | string | `"HOME"` |  |
| containers.env[0].value | string | `"/home"` |  |
| containers.env[1].name | string | `"HF_HOME"` |  |
| containers.env[1].value | string | `"/home/.cache/hf_home"` |  |
| containers.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| containers.securityContext.runAsUser | int | `1000` |  |
| containers.volumeMounts[0].mountPath | string | `"/tmp"` |  |
| containers.volumeMounts[0].name | string | `"temp-dir"` |  |
| containers.volumeMounts[1].mountPath | string | `"/home"` |  |
| containers.volumeMounts[1].name | string | `"home"` |  |
| fullnameOverride | string | `""` |  |
| image.containerPort | int | `8000` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"whylabs/whylogs"` |  |
| image.tag | string | `"py-llm-1.0.2.dev4"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| initContainers.command[0] | string | `"sh"` |  |
| initContainers.command[1] | string | `"-c"` |  |
| initContainers.command[2] | string | `"cp -R /opt/whylogs-container/.cache /home/"` |  |
| initContainers.volumeMounts[0].mountPath | string | `"/home"` |  |
| initContainers.volumeMounts[0].name | string | `"home"` |  |
| livenessProbe.initialDelaySeconds | int | `15` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.tcpSocket.port | int | `8000` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| pod.annotations | object | `{}` |  |
| pod.labels | object | `{}` |  |
| pod.securityContext | object | `{}` |  |
| readinessProbe.initialDelaySeconds | int | `15` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| readinessProbe.tcpSocket.port | int | `8000` |  |
| replicaCount | int | `3` |  |
| resources.limits.cpu | string | `"8"` |  |
| resources.limits.memory | string | `"16Gi"` |  |
| resources.requests.cpu | string | `"4"` |  |
| resources.requests.memory | string | `"8Gi"` |  |
| secrets.langkitApiSecret | object | `{"name":"langkit-api-secret"}` | from-literal=CONTAINER_PASSWORD=<llangkit-api-secret> |
| secrets.whylabsApiKey | object | `{"name":"whylabs-api-key"}` | from-literal=WHYLABS_API_KEY=<whylabs-api-key> |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automount | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
| volumes[0].emptyDir | object | `{}` |  |
| volumes[0].name | string | `"temp-dir"` |  |
| volumes[1].emptyDir | object | `{}` |  |
| volumes[1].name | string | `"home"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.12.0](https://github.com/norwoodj/helm-docs/releases/v1.12.0)
