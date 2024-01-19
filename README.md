# Helm Charts for WhyLabs

## How to use WhyLabs Helm repository

```shell
helm_repo="ghcr.io/whylabs"
chart_name="langkit"
chart_version="0.1.0"
chart="${chart_name}-${chart_version}.tgz"

# Release and namespace values mirror other variables for simplicity.
# Set these to as desired
release="${chart_name}"
namespace="${release}"


# Downloads <chart_name>-<chart_version>.tgz to your current directory
helm pull \
  "oci://${helm_repo}/${chart_name}" \
  --version "${chart_version}"

helm diff upgrade \
  `# --allow-unreleased will show a diff for a new install` \
  --allow-unreleased \
  `# set namespace.create to false if the target namespace already exists` \
  --set namespace.create=false \
  --namespace "${namespace}" \
  "${release}" .

# Specify the .tgz file as the na
helm upgrade --install \
  `# set namespace.create to false if the target namespace already exists` \
  --set namespace.create=false \
  --namespace "${namespace}" \
  "${release}" .

# Uninstall
helm uninstall \
  --namespace "${namespace}" \
  "${release}"
```