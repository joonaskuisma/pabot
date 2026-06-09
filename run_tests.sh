#!/bin/bash
set -e

# Activate virtual environment
source .venv/bin/activate || . .venv/Scripts/activate

# Ensure dependencies are up to date
pip install -U pip setuptools wheel
pip install -r requirements.txt
pip install -e .

# Run tests with coverage
echo "Running test suite..."
pytest tests -v --tb=short --cov=src/pabot --cov-report=term-missing

echo "✓ All tests passed!"
