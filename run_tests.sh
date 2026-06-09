#!/bin/bash
set -e

# Activate virtual environment
if [ -f .venv/bin/activate ]; then
  source .venv/bin/activate
elif [ -f .venv/Scripts/activate ]; then
  . .venv/Scripts/activate
else
  echo "No virtualenv activate script found in .venv/bin or .venv/Scripts"
  exit 1
fi

# Ensure dependencies are up to date
pip install -U pip setuptools wheel
pip install -r requirements.txt
pip install -e .

# Run tests with coverage
echo "Running test suite..."
pytest tests -v --tb=short --cov=src/pabot --cov-report=term-missing

echo "✓ All tests passed!"
