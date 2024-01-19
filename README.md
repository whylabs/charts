# Helm Charts for WhyLabs

## How to use WhyLabs Helm repository

### Example Using the [LangKit Helm Chart](./charts/langkit/)

#### Quick Start
```shell
helm pull \
  oci://ghcr.io/whylabs/langkit \
  --version "0.2.0"

helm diff upgrade \
  --allow-unreleased \
  `# set namespace.create to false if the target namespace already exists` \
  --set namespace.create=false \
  --namespace langkit \
  langkit langkit-0.2.0.tgz

helm upgrade --install \
  `# set namespace.create to false if the target namespace already exists` \
  --set namespace.create=false \
  --namespace langkit \
  langkit langkit-0.2.0.tgz
```

#### Extended Example
```shell
# Configure local variables for clarity and simplicity
helm_repo="ghcr.io/whylabs"
chart_name="langkit"
chart_version="0.2.0"
chart="${chart_name}-${chart_version}.tgz"

# Release and namespace values mirror other variables for simplicity.
# Set these to as desired
release="${chart_name}"
namespace="${release}"

# Downloads <chart_name>-<chart_version>.tgz to your current directory
helm pull \
  "oci://${helm_repo}/${chart_name}" \
  --version "${chart_version}"

# Performs a diff between current and proposed state
# --allow-unreleased flag will perform a diff even if there is no current state,
# i.e. a fresh installation will display all net new resource creation in the diff.
# --set namespace.create=false must be set if target namespace already exists;
# omit this line or set it to "true" if the target namespace should be created.
# Requires the helm-diff plugin to be installed:
# helm plugin install https://github.com/databus23/helm-diff
helm diff upgrade \
  --allow-unreleased \
  `# set namespace.create to false if the target namespace already exists` \
  --set namespace.create=false \
  --namespace "${namespace}" \
  "${release}" "${chart}"

# helm upgrade --install supports installation and upgrades.
# In the `helm upgrade --install <release-name> <chart>` command, the chart may be
# a chart reference('example/postgres'), a path to a chart directory, a fully qualified
# URL, or a packaged chart (which is what this example uses)
helm upgrade --install \
  `# set namespace.create to false if the target namespace already exists` \
  --set namespace.create=false \
  --namespace "${namespace}" \
  "${release}" "${chart}"

# Uninstall
helm uninstall \
  --namespace "${namespace}" \
  "${release}"
```
