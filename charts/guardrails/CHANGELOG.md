# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning]
(https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2024-10-15

### Updated

- Removed default `envFrom` secrets from `deployment.yaml` template for cases
  where secrets are managed via other methods.

## [0.2.2] - 2024-09-04

### Updated

- Default image tag from `1.0.23` to `2.0.1`

### Fixed

- `extraVolumeMounts` was not adding volume mounts as expected.

## [0.2.1] - 2024-07-25

### Updated

- Default image tag from `1.0.20-dev2` to `1.0.23`
- Allow `imagePullSecrets` to be excluded from the `Deployment` if set to `[]`

## [0.2.0] - 2024-05-14

### Updated

- Default image tag from `1.0.19` to `1.0.20-dev2`

## [0.1.0] - 2024-05-08

### Added

- Initial release of `guardrails` Helm chart
