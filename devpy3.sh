#!/bin/sh
# Setup dev environment for Python 3.10+
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi

source .venv/bin/activate || . .venv/Scripts/activate
pip install -U pip setuptools wheel
pip install -r requirements.txt
pip install -e .

echo "Development environment ready!"
echo "Run: source .venv/bin/activate  (on Linux/macOS)"
echo "Run: .venv\\Scripts\\activate    (on Windows)"
