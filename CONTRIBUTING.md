# Contributing to pabot

Thank you for your interest in contributing to **pabot**! 🎉
All kinds of contributions are welcome — bug reports, feature requests, documentation improvements, and code contributions.

This document explains how to participate effectively and how we organize communication.

---

## Table of Contents

- [Ways to Contribute](#ways-to-contribute)
- [Issues vs Discussions](#issues-vs-discussions)
  - [Issues (for actionable work)](#issues-for-actionable-work)
  - [Discussions (for questions and conversation)](#discussions-for-questions-and-conversation)
- [Before Opening an Issue](#before-opening-an-issue)
- [Bug Reports](#bug-reports)
- [Feature Requests](#feature-requests)
- [Development Setup](#development-setup)
- [Running Tests](#running-tests)
- [Code Quality](#code-quality)
- [Pull Requests](#pull-requests)
- [Release Process](#release-process)
- [Code of Conduct](#code-of-conduct)
- [Getting Help](#getting-help)

---

## Ways to Contribute

You can contribute by:

- Reporting bugs
- Suggesting new features or improvements
- Asking and answering questions
- Improving documentation
- Submitting pull requests
- Adding tests and improving test coverage

---

## Issues vs Discussions

To keep things organized, we use **Issues** and **Discussions** for different purposes.

### Issues (for actionable work)
Use an **Issue** when you have:

- A reproducible bug
- A feature request or enhancement
- A clearly defined technical task that likely leads to code changes

Please use the provided **issue templates** when opening a new issue.

👉 Rule of thumb: *Issues usually result in a fix, change, or pull request.*

---

### Discussions (for questions and conversation)
Use **Discussions** when you have:

- Usage or "How do I…?" questions
- General support requests
- Open-ended ideas or design discussions
- Requests for advice or clarification

Please post questions in **Discussions → Q&A**.

👉 Rule of thumb: *Discussions usually end with an answer or decision, not necessarily code.*

Issues that are primarily Q&A may be converted into Discussions by maintainers.

---

## Before Opening an Issue

Please check:

1. Existing issues (open and closed)
2. Existing discussions
3. Project documentation and README

This helps avoid duplicates and speeds up responses.

---

## Bug Reports

When reporting a bug:

- Use the **Bug Report** issue template
- Include clear steps to reproduce
- Describe expected vs actual behavior
- Mention relevant versions and environment details:
  - Python version (`python --version`)
  - Robot Framework version (`robot --version`)
  - Pabot version (`pabot --version`)
  - OS (Linux, macOS, Windows)

Well-written bug reports are much easier to fix ❤️

---

## Feature Requests

When suggesting a feature:

- Use the **Feature Request** issue template
- Explain the problem you are trying to solve
- Describe your proposed solution if you have one
- Consider edge cases and impact on existing functionality

Feature requests are discussed openly and may take time to prioritize.

---

## Development Setup

### Prerequisites

- Python 3.10 or newer
- Git

### Setting up your environment

1. **Fork and clone** the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/pabot.git
   cd pabot
   ```

2. **Create a virtual environment** and install dependencies:
   ```bash
   # macOS/Linux
   chmod +x devpy3.sh
   ./devpy3.sh

   # Windows
   python -m venv .venv
   .venv\Scripts\activate
   pip install -r requirements.txt
   pip install -e .
   ```

3. **Install pre-commit hooks** (recommended):
   ```bash
   pre-commit install
   ```
   This ensures your code passes quality checks before committing.

---

## Running Tests

### Run all tests
```bash
pytest tests
```

### Run specific test file
```bash
pytest tests/test_pabot.py
```

### Run with coverage report
```bash
pytest tests --cov=src/pabot --cov-report=html
```
Open `htmlcov/index.html` to view the report.

### Run only fast tests (skip slow integration tests)
```bash
pytest tests -m "not slow"
```

### Using the test script
```bash
bash run_tests.sh
```

---

## Code Quality

We maintain code quality with the following tools:

### Formatting
- **black**: Code formatting (line length: 100)
- **isort**: Import sorting

### Linting
- **ruff**: Fast Python linter (replaces flake8)
- **pylint**: Additional code quality checks

### Type Checking
- **mypy**: Static type checking

### Running quality checks manually
```bash
# Format code
black src tests
isort src tests

# Lint
ruff check src tests --fix
pylint src

# Type check
mypy src
```

### Automatic checks with pre-commit
If you installed pre-commit hooks, they run automatically on commit.
To run them manually:
```bash
pre-commit run --all-files
```

---

## Pull Requests

Pull requests are very welcome!

### Before you start
- Create an issue first if one doesn't exist
- Link your PR to the issue
- Keep PRs focused and reasonably small (ideally < 400 lines)

### General guidelines

1. **Create a descriptive branch name**:
   ```bash
   git checkout -b fix/issue-name
   git checkout -b feature/new-capability
   ```

2. **Write clear commit messages**:
   - First line: clear summary (50 chars max)
   - Blank line
   - Detailed explanation if needed
   - Reference issues: "Fixes #123" or "Related to #456"

3. **Code guidelines**:
   - Follow existing code style and conventions
   - Add or update tests if applicable (aim for >80% coverage)
   - Update documentation if behavior changes
   - Use type hints where reasonable

4. **Update CHANGELOG** if needed:
   - Describe user-facing changes
   - Link to related issue/PR

5. **Ensure all checks pass**:
   ```bash
   bash run_tests.sh          # Run tests
   pre-commit run --all-files # Run quality checks
   ```

### PR description template

```markdown
## Description
Clear description of what this PR does.

## Related Issue
Closes #123

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Documentation update

## Testing
Describe tests added or how this was tested.

## Checklist
- [ ] Tests pass locally
- [ ] Code follows style guidelines (`black`, `isort`, `ruff`)
- [ ] New/updated code has tests
- [ ] Documentation updated if needed
- [ ] No new warnings generated
```

---

## Release Process

### For maintainers

1. **Update version number**:
   - Edit [src/pabot/__init__.py](src/pabot/__init__.py): `__version__` variable
   - Update CHANGELOG with release notes
   - Commit: `git commit -am "Bump version to X.Y.Z"`

2. **Create a git tag**:
   ```bash
   git tag X.Y.Z
   git push origin X.Y.Z
   ```
   GitHub Actions will automatically:
   - Run all tests
   - Build distributions
   - Upload to PyPI

3. **Create release notes** on GitHub with the CHANGELOG entries

4. **Verify release**:
   ```bash
   pip install --upgrade robotframework-pabot
   ```

---

## Code of Conduct

Please be respectful and constructive in all interactions.

We want pabot to be a welcoming project for everyone, regardless of experience level.

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for details.

---

## Getting Help

If you're unsure where your contribution fits:

- Open a **Discussion**
- Ask in **Discussions → Q&A**
- Check existing issues and PRs

We're happy to help guide you in the right direction 🙂

---

Thanks again for contributing to **pabot**! 🚀
