# Build & Deploy Guide

This document describes pabot's build and deployment infrastructure.

## Overview

Pabot uses:
- **GitHub Actions** for CI/CD
- **PyPI** for package distribution
- **Semantic Versioning** for releases

## CI/CD Pipeline

### GitHub Actions Workflows

Located in `.github/workflows/`:

#### `ci.yml` (Main CI Pipeline)
Runs on every push and pull request:

1. **Lint Job**
   - Checks code style with `ruff`, `black`, `isort`
   - Runs type checking with `mypy`
   - Runs once on Python 3.10

2. **Test Job** (Matrix)
   - Tests on Linux, macOS, Windows
   - Python versions: 3.10, 3.12, 3.14 (when available)
   - Robot Framework versions: 7.0.1, 7.2.2, latest
   - Generates coverage reports
   - Uploads to Codecov

3. **Compatibility Job**
   - Validates packaging with `build` and `twine`
   - Ensures distributions can be created

4. **Result Job**
   - Aggregates all job results
   - Fails if any job failed

#### `release.yml`
Triggers on version tags:
- Validates version format (X.Y.Z)
- Runs full test suite
- Builds distributions
- Uploads to PyPI

#### `nightly-rf-compat.yml`
Runs nightly to test against latest Robot Framework:
- Catches RF compatibility issues early

### Local Development

#### Prerequisites
- Python 3.10+
- Git

#### Setup

```bash
# Clone repo
git clone https://github.com/mkorpela/pabot.git
cd pabot

# Create virtual environment
python -m venv .venv

# Activate (macOS/Linux)
source .venv/bin/activate

# Activate (Windows)
.venv\Scripts\activate

# Install dev dependencies
pip install -r requirements.txt
pip install -e .

# Install pre-commit hooks
pre-commit install
```

#### Running Tests Locally

```bash
# Run all tests
pytest tests

# Run with coverage
pytest tests --cov=src/pabot --cov-report=html

# Run with specific Python version
pyenv local 3.10.0  # if using pyenv
pytest tests

# Run only unit tests (skip slow)
pytest tests -m "not slow"
```

#### Code Quality Checks

```bash
# Format code (auto-fix)
black src tests
isort src tests

# Lint (auto-fix enabled)
ruff check src tests --fix

# Type checking
mypy src

# Run all checks
pre-commit run --all-files
```

## Building Distributions

### Local Build

```bash
pip install build twine

# Build distributions
python -m build

# Check before upload
twine check dist/*

# Verify package contents
tar -tzf dist/*.tar.gz | head -20
unzip -l dist/*.whl | head -20
```

### PyPI Upload

Only maintainers:

```bash
# Upload to test PyPI first (recommended)
twine upload -r testpypi dist/*

# Upload to production PyPI
twine upload dist/*
```

## Release Process

### 1. Prepare Release

```bash
# Create/switch to release branch
git checkout -b release/v6.0.0

# Update version in src/pabot/__init__.py
echo '__version__ = "6.0.0"' > src/pabot/__init__.py

# Update CHANGELOG.md
# Add release notes with:
# - [6.0.0] - YYYY-MM-DD
# - What's new (Added, Changed, Fixed, etc.)

# Commit changes
git add -A
git commit -m "Bump version to 6.0.0"

# Create PR, get reviews, merge to main
```

### 2. Tag Release

```bash
# Ensure you're on main branch
git checkout main
git pull origin main

# Create git tag
git tag 6.0.0

# Push tag (triggers GitHub Actions)
git push origin 6.0.0

# Verify tag exists
git tag -l 6.0.0 -n1
```

### 3. GitHub Actions Handles:

- Validates version format
- Runs entire test suite
- Builds distributions (wheel + source)
- Uploads to PyPI automatically
- Creates draft release notes

### 4. Post-Release

```bash
# Verify on PyPI
pip install --upgrade --force-reinstall robotframework-pabot

# Verify version
python -c "import pabot; print(pabot.__version__)"

# Create GitHub release
# Go to Releases → Draft → Edit → Publish
# Add detailed release notes from CHANGELOG.md
```

## Troubleshooting

### Build Failures

**Issue**: `python -m build` fails
```bash
# Ensure setuptools is up to date
pip install --upgrade pip setuptools wheel

# Clean build artifacts
rm -rf build dist src/*.egg-info

# Try again
python -m build
```

**Issue**: Import errors during build
- Check that `src/pabot/__init__.py` is valid
- Ensure Robot Framework is installed: `pip install robotframework`

### Test Failures in CI

1. Check CI logs in GitHub Actions
2. Reproduce locally with same Python/RF version
3. Check for environment-specific issues:
   ```bash
   python --version
   robot --version
   pip list | grep -E "robotframework|pabot"
   ```

### Release Issues

**Issue**: Tag push doesn't trigger workflow
- Ensure tag format is semantic: X.Y.Z
- Check workflows are enabled in repo settings
- Verify GitHub Actions permissions

**Issue**: PyPI upload fails
- Check PyPI credentials in repository secrets
- Verify token has upload permissions
- Check package metadata with: `twine check dist/*`

## Secrets Management

GitHub repository secrets needed for CI/CD:

- `PYPI_API_TOKEN`: PyPI API token for automatic uploads

Set in: Repository Settings → Secrets and variables → Actions

## Python Version Support Policy

Currently supported:
- 3.10 (minimum required)
- 3.11, 3.12, 3.13, 3.14

New Python versions:
- Add to CI matrix in `.github/workflows/ci.yml`
- Update classifiers in `setup.cfg`
- Update `pyproject.toml` targets

End-of-life versions are dropped in major releases.

## Performance Optimization

### CI Optimization
- Matrix test strategy excludes redundant combinations
- Uses GitHub Actions caching for pip packages
- Runs linting once (not per Python version)
- Concurrent jobs with `concurrency` group

### Build Optimization
- Cache reused across similar job configs
- Download cache ~30s, saves ~2min per job

## Additional Resources

- [Setuptools Documentation](https://setuptools.pypa.io/)
- [Python Packaging Guide](https://packaging.python.org/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
