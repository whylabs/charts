# Helm Charts for WhyLabs

## How to Use WhyLabs Helm Repository

> :warning: WhyLab's Helm charts are currently hosted on the GitHub Container
> Registry (GHCR), an OCI-compliant storage solution. While GHCR differs from
> traditional Helm repositories by not providing an `index.yaml` file for chart
> listings, it aligns with industry standards for container artifact storage. As
> we explore more comprehensive repository solutions, please use the `helm pull`
> command, followed by specifying the chart's `.tgz` file, to access and utilize
> our Helm charts.

### Example Using the [Guardrails Helm Chart](./charts/guardrails/)

#### Quick Start

```shell
chart_version=""

# The following command will download a guardrails-${chart_version}.tgz file to
# the working directory or --destination path
helm pull \
  oci://ghcr.io/whylabs/guardrails \
  --version "${chart_version}"

# Requires the helm-diff plugin to be installed:
# helm plugin install https://github.com/databus23/helm-diff
helm diff upgrade \
  --allow-unreleased \
  --namespace guardrails \
  guardrails "guardrails-${chart_version}.tgz"

helm upgrade --install \
  --create-namespace \
  --namespace guardrails \
  guardrails "guardrails-${chart_version}.tgz"
```

#### Extended Example
```shell
# Configure local variables for clarity and simplicity
helm_repo="ghcr.io/whylabs"
chart_name="guardrails"
chart_version="1.0.0"
chart_file="${chart_name}-${chart_version}.tgz"
namespace="default"

# Downloads ${chart_name}-${chart_version}.tgz to your current directory
helm pull \
  "oci://${helm_repo}/${chart_name}" \
  --version "${chart_version}"

# Perform a diff between current and proposed state
# Requires the helm-diff plugin to be installed:
# `helm plugin install https://github.com/databus23/helm-diff`
helm diff upgrade \
  --allow-unreleased \
  --namespace "${namespace}" \
  "${chart_name}" "${chart_file}"

# helm upgrade --install supports initial installation and upgrades.
# In the `helm upgrade --install <release-name> <chart>` command, the chart may
# be a chart reference('example/postgres'), a path to a chart directory, a fully
# qualified URL, or a packaged chart (.tgz), which is what this example uses.
helm upgrade --install \
  --create-namespace \
  --namespace "${namespace}" \
  "${chart_name}" "${chart_file}"

# Uninstall
helm uninstall \
  --namespace "${namespace}" \
  "${chart_name}"
```

## Development

### Pre-Commit

#### Troubleshooting

Try executing `pre-commit` manually if it fails on commit:

```shell
git add .
pre-commit run --all-files
```
