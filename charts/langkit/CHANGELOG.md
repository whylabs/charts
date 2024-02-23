# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning]
(https://semver.org/spec/v2.0.0.html).

## [0.12.0] - 2023-02-23

### Changed

- Updated default image from `py-llm-1.0.5` to `py-llm-1.0.6`

### Fixed

- Use correct probe endpoint.

## [0.11.0] - 2023-02-22

### Changed

- Updated default image from `py-llm-1.0.2.dev10` to `py-llm-1.0.5`.

## [0.10.0] - 2023-02-19

### Added

- Recommendation for Intel processors and `6 GiB` of memory per pod.

### Changed

- Updated default image tag from `py-llm-1.0.2.dev6` to `py-llm-1.0.2.dev10`.
- Changed replica count from `3` to `4` for improved performance.
- Updated resource requests and limits for improved performance.

### Removed

- Removed the init container.

## [0.9.0] - 2023-02-15

### Added

- Added `TRANSFORMERS_OFFLINE` and `HF_DATASETS_OFFLINE` environment variables.

## [0.8.0] - 2023-02-14 :heart:

### Added

- Added managed `ServiceAccount` with configurations for `annotations` to
  support authentication methods such as AWS IRSA.

## [0.7.0] - 2023-02-12

### Changed

- Updated default image tag from `py-llm-1.0.2.dev2` to `py-llm-1.0.2.dev4`

## [0.6.0] - **Breaking Changes** - 2023-02-01

### Breaking

- :warning: changed the structure of the `values.yaml` file for better
  organization with the introduction of an init container and running as a
  non-root user by default

### Changed

- Updated the `securityContext` to run the container as a non-root user

### Added

- Added an `initContainer`
- Added support for configuring container environment variables

### Removed

- Removed default `root-config` volume and volume mount

## [0.5.0] - 2023-01-30

### Changed

- Updated the default image version from `py-llm-1.0.2.dev0` to `py-llm-1.0.2.dev1`
- Default `tolerations` is set to `[]`

## [0.4.0] - **Breaking Changes** - 2023-01-26

### Added

- `readOnlyRootFilesystem` is set to `true` by default.
- Added two volumes to allow writes at specific paths.

### Breaking

- :warning: Removed `Namespace` management by this Helm chart in accordance with
  best practices. If deploying into a `Namespace` that does not exist, you must
  include the `--create-namespace` flag.

### Fixed

- The documentation for the `langkit-api-secret` secret incorrectly specifies
  the key ``--from-literal=LANGKIT_API_KEY=<langkit-api-key>`. The correct
  configuration for the secret is
  `--from-literal=CONTAINER_PASSWORD=<langkit-api-key>`. 

### Removed

- `ServiceAccount` is not required by LangKit at this time.

## [0.3.0] - 2024-01-23

### Added

- Ingress resource

### Changed

- Documented working with GitHub Container Registry (GHCR), an OCI-compliant
  storage solution 
