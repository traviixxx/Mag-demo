# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

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
