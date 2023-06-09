# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [v1.7.0] - 2023-02-14

### Added

- [MR-95](https://gitlab.com/mironet/magnolia-helm/-/merge_requests/95)
  PodDisruptionBudget for magnolia publics.
  ⚠️ This will break compatibility with Kubernetes <= 1.20. You will need at least Kubernetes 1.21 going onward from here.

### Changed

- Upgrade magnolia-backup mainline from `v0.7-mainline` to
  [`v0.8-mainline`](https://gitlab.com/mironet/magnolia-backup/-/blob/master/CHANGELOG.md)
  (adding Azure Blob Storage support).

## [v1.6.5] - 2023-02-10

### Fixed

- [MR-94](https://gitlab.com/mironet/magnolia-helm/-/merge_requests/94)
  Fix configMap syntax error on some values.yml combinations.

## [v1.6.4] - 2023-02-06

### Changed

- Don't reference patch version in image tags.

  Use release train tags instead.

  This is done for images:
  - magnolia-backup (uses `v0.7-mainline` now)
  - magnolia-bootstrap (uses `v0.5-mainline` now)
  - redirects (uses `v0.3-mainline` now)

  By using release train tags, no more new helm versions are required for simple
  bugfix releases. Instead the release train tag will always point to the latest
  bugfix version.

  > Note: But one might still need to remove and re-pull the image on the
  > cluster on which the helm release resides.

## [v1.6.3] - 2023-02-01

### Changed

- Upgrade redirects server version from `v0.3.0` to
  [`v0.3.1`](https://gitlab.com/mironet/redirects/-/blob/main/CHANGELOG.md#v031-2023-01-23).

## [v1.6.2] - 2023-01-25

### Changed

- Upgrade magnolia-backup version from `v0.7.3` to
  [`v0.7.4`](https://gitlab.com/mironet/magnolia-backup/-/blob/master/CHANGELOG.md#v074-2023-01-25).

## [v1.6.1] - 2023-01-23

### Changed

- Upgrade magnolia-backup version from `v0.6.0` to
  [`v0.7.3`](https://gitlab.com/mironet/magnolia-backup/-/blob/master/CHANGELOG.md#v073-2023-01-19).

## [v1.6.0] - 2023-01-17

### Added

- Helm value to activate redirects server for public instances.
- Create empty redirects config map if it does not already exists.
- s3-backup-key migration script.

## [v1.5.15] - 2023-01-10

### Added

- Set env var `MGNLBACKUP_TAGS_NAMESPACE` in backup container.

### Changed

- Always set env var `MGNLBACKUP_TAGS_POD_NAME` in backup container.
- Upgrade magnolia-backup version from `v0.5.14` to
  [`v0.6.0`](https://gitlab.com/mironet/magnolia-backup/-/blob/master/CHANGELOG.md#v060-2023-01-10).

## [v1.5.14] - 2022-12-15

### Added

- Upgrade magnolia-backup version from `v0.5.11` to `v0.5.14`.

## [v1.5.13] - 2022-11-24

### Added

- [MR-85](https://gitlab.com/mironet/magnolia-helm/-/merge_requests/85)
  Expose backup metrics.

  - Add service for metrics ports if backup is enabled.
  - Closed #49

### Changed

- Also: Bump default memory allocation for Magnolia.

## [v1.5.12] - 2022-11-23

### Fixed

- [MR-83](https://gitlab.com/mironet/magnolia-helm/-/merge_requests/83)
  Activation keypair lost on restart when the magnoliaAuthor.useExistingSecret =
  false and the activation.privateKey is not specified in the Helm chart values.

## [v1.5.4] - 2022-04-06

Bugfix release regarding backups and several upgrades of underlying software.

### Added

- [MR-70](https://gitlab.com/mironet/magnolia-helm/-/merge_requests/70)
  Make the websocket deactivation in Tomcat configurable

### Changed

- [MR-72](https://gitlab.com/mironet/magnolia-helm/-/merge_requests/72)
  Change the default tomcat docker image tag to 9.0-jre11-temurin
- [MR-74](https://gitlab.com/mironet/magnolia-helm/-/merge_requests/74)
  Remove unneeded archive volume from statefulsets.
- [MR-75](https://gitlab.com/mironet/magnolia-helm/-/merge_requests/75)
  Bump magnolia-backup version.

### Fixed

- [MR-71](https://gitlab.com/mironet/magnolia-helm/-/merge_requests/71)
  Update Ingress to from deprecated 'extensions/v1beta1' to 'networking.k8s.io/v1' K8s API
- [MR-73](https://gitlab.com/mironet/magnolia-helm/-/merge_requests/73)
  Fix/ingress network api v1 doc

## [v1.5.0] - 2022-02-24

Version v1.5.0 changes the underlying backup system when using `pg_wal` archiving. This means existing deployments need to be removed and redeployed. See the section about [upgrades in the readme](https://gitlab.com/mironet/magnolia-helm/-/tree/master#upgrade).

### Added

- [MR-65](https://gitlab.com/mironet/magnolia-helm/-/merge_requests/65)
  Allow more fine-grained configuration of Tomcat/JVM.

### Changed

- [MR-69](https://gitlab.com/mironet/magnolia-helm/-/merge_requests/69)
  Allow for author-less or public-less deployment.
- [MR-67](https://gitlab.com/mironet/magnolia-helm/-/merge_requests/67)
  Implement new backup system, transferring the base backup more efficiently.

### Fixed
