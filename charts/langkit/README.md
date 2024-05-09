# langkit

> **:exclamation: This Helm Chart is deprecated!**

![Version: 0.16.0](https://img.shields.io/badge/Version-0.16.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.13](https://img.shields.io/badge/AppVersion-1.0.13-informational?style=flat-square)

A Helm chart for LangKit container deployment

> :warning: Review the [documentation on using WhyLab's Helm charts](../../README.md#how-to-use-whylabs-helm-repository)

## Prerequisites

NOTE: Change the `--namespace` value to the target `Namespace` to deploy the
service.

### Credentials
* Create a [WhyLabs API Key](https://docs.whylabs.ai/docs/whylabs-capabilities/#access-token-management)
which must be stored in a `whylabs-api-key` Kubernetes secret, described below.

```shell
kubectl create secret generic whylabs-api-key \
  --namespace=<namespace> \
  --from-literal=WHYLABS_API_KEY=<whylabs-api-key>
```

* Generate a random value for the `langkit-api-secret` Kubernetes secret, also
described below. **This secret is required to call the container API endpoint**.

```
kubectl create secret generic langkit-api-secret \
  --namespace=<namespace> \
  --from-literal=CONTAINER_PASSWORD=<langkit-api-secret>
```

* Create a secret with a WhyLabs provided GitLab token to pull the LangKit image

```
kubectl create secret docker-registry langkit-gitlab-registry-secret \
  --docker-server="registry.gitlab.com" \
  --docker-username="project_55361491_bot_5a6afbd67224dd1583ccd6c7987354c3" \
  --docker-password="<token>" \
  --docker-email="project_55361491_bot_5a6afbd67224dd1583ccd6c7987354c3@noreply.gitlab.com" \
  --namespace=<namespace>
```

### LangKit Configuration

No LangKit configurations are required out of the box. However, for further customizations,
review the [langkit-container-examples](https://github.com/whylabs/langkit-container-examples)
repository for more details.

### Hardware Requirements

:rocket: For best performance, use Intel processors and ≥ `6 GiB` memory per replica.

## Helm Chart Installation

### Template
Display the full YAML manifests as they will be applied.

```shell
# This will use the "langkit" namespace
helm template --namespace <namespace> langkit .
```

### Diff
View the difference between the current state and desired state.

```shell
# Requires the helm-diff plugin to be installed:
# helm plugin install https://github.com/databus23/helm-diff
helm diff upgrade \
  --allow-unreleased \
  langkit langkit-0.16.0.tgz
```

### Install/Update
```shell
helm upgrade --install \
  --create-namespace \
  --namespace <namespace> \
  langkit langkit-0.16.0.tgz
```

### Uninstall
```shell
helm uninstall \
  --namespace <namespace> \
  langkit langkit-0.16.0.tgz
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| containers.env | list | `[]` | Environment variables for the containers |
| containers.securityContext | object | `{"readOnlyRootFilesystem":true,"runAsUser":1000}` | Container security context |
| containers.volumeMounts | list | `[{"mountPath":"/tmp","name":"temp-dir"}]` | Volume mounts for containers |
| fullnameOverride | string | `""` |  |
| image.containerPort | int | `8000` |  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"registry.gitlab.com/whylabs/langkit-container"` |  |
| image.tag | string | `"1.0.13"` |  |
| imagePullSecrets[0].name | string | `"langkit-gitlab-registry-secret"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts | list | `[]` |  |
| ingress.tls | list | `[]` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.httpGet.path | string | `"/health"` |  |
| livenessProbe.httpGet.port | int | `8000` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `30` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| pod.annotations | object | `{}` |  |
| pod.labels | object | `{}` |  |
| pod.securityContext | object | `{}` |  |
| readinessProbe.failureThreshold | int | `10` |  |
| readinessProbe.httpGet.path | string | `"/health"` |  |
| readinessProbe.httpGet.port | int | `8000` |  |
| readinessProbe.initialDelaySeconds | int | `30` |  |
| readinessProbe.periodSeconds | int | `30` |  |
| replicaCount | int | `2` | Number of replicas for the service. |
| resources.limits.cpu | string | `"4"` |  |
| resources.limits.memory | string | `"4Gi"` |  |
| resources.requests.cpu | string | `"4"` |  |
| resources.requests.memory | string | `"4Gi"` |  |
| secrets.langkitApiSecret.name | string | `"langkit-api-secret"` | Name of the secret that stores the WhyLabs LangKit API Secret |
| secrets.whylabsApiKey.name | string | `"whylabs-api-key"` | Name of the secret that stores the WhyLabs API Key |
| service.annotations | object | `{}` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automount | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
| volumes | list | `[{"emptyDir":{},"name":"temp-dir"}]` | Volumes to create |

----------------------------------------------

Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs/).