# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- (upcoming changes will be listed here)

### Changed
- (upcoming changes will be listed here)

### Fixed
- (upcoming bug fixes will be listed here)

### Deprecated
- (upcoming deprecations will be listed here)

### Removed
- (upcoming removals will be listed here)

---

## [6.0.0] - 2026-06-10

### Changed
- **BREAKING**: Bump minimum Python version from 3.6 to 3.10
- **BREAKING**: Bump minimum Robot Framework version from 3.2 to 7.0
- Updated all development dependencies to latest versions (2026)
- Modernized build system with setuptools 65+
- Enhanced code quality tooling (ruff replaces flake8, modern mypy config)

### Added
- Support for Python 3.13 and 3.14
- Pre-commit hooks configuration (`.pre-commit-config.yaml`)
- Type annotations in `pyproject.toml` (PEP 621 compliance)
- Improved MANIFEST.in for complete distribution packaging
- Comprehensive developer guide in CONTRIBUTING.md
- Code coverage reporting in CI/CD pipeline
- Joonas Kuisma as maintainer

### Removed
- Python 2 support scripts (devpy2.sh, mypy.py2.ini)
- Legacy testing infrastructure
- Outdated mypy.ini configuration

### Fixed
- Proper package metadata and author information
- Improved .gitignore organization

---

## [5.2.2] - Earlier versions

See GitHub releases for earlier changelog entries.

[Unreleased]: https://github.com/mkorpela/pabot/compare/6.0.0...HEAD
[6.0.0]: https://github.com/mkorpela/pabot/releases/tag/6.0.0
