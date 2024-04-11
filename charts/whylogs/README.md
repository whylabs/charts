# WhyLogs Helm Chart

See [WhyLogs Documentation](https://docs.whylabs.ai/docs/integrations-whylogs-container/)
for more information

> :warning: Review the [documentation on using WhyLab's Helm charts](../../README.md#how-to-use-whylabs-helm-repository)

## Prerequisites

### Secrets

The following configured secrets must exist in the cluster prior to deploying
the WhyLogs Helm chart.

Create a [WhyLabs API Key](https://docs.whylabs.ai/docs/whylabs-capabilities/#access-token-management)
which must be stored in a `whylabs-api-key` Kubernetes secret, described below.


```shell
whylabs_api_key=""
whylogs_password=""
namespace="default"

kubectl create secret generic whylabs-api-key \
  --namespace "${namespace}" \
  --from-literal=api-key="${whylabs_api_key}"

kubectl create secret generic whylogs-container-password \
  --namespace "${namespace}" \
  --from-literal=passwordy="${whylogs_password}"
```

## Deployment

### Diff
View the difference between the current state and desired state.

```shell
# Requires the helm-diff plugin to be installed:
# helm plugin install https://github.com/databus23/helm-diff
helm diff upgrade \
  --allow-unreleased \
  whylogs "whylogs-${chart_version}.tgz"
```

### Install/Update
```shell
helm upgrade --install \
  --create-namespace \
  --namespace "${namespace}" \
  whylogs "whylogs-${chart_version}.tgz"
```

### Uninstall
```shell
helm uninstall \
  --namespace "${namespace}" \
  whylogs "whylogs-${chart_version}.tgz"
```
