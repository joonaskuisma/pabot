#!/usr/bin/env bash

set -e

RF_DIR="robotframework"
VENV_DIR=".venv/robotframework-atest"
REQUIRED_PYTHON_MAJOR=3
REQUIRED_PYTHON_MINOR=8

check_python_version() {
  if ! command -v python &>/dev/null; then
    echo "❌ Python is not installed or not in PATH"
    exit 1
  fi

  PYTHON_VERSION=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
  PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
  PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)

  if [ "$PYTHON_MAJOR" -lt "$REQUIRED_PYTHON_MAJOR" ] || { [ "$PYTHON_MAJOR" -eq "$REQUIRED_PYTHON_MAJOR" ] && [ "$PYTHON_MINOR" -lt "$REQUIRED_PYTHON_MINOR" ]; }; then
    echo "❌ Python $REQUIRED_PYTHON_MAJOR.$REQUIRED_PYTHON_MINOR+ is required. Found: $PYTHON_VERSION"
    exit 1
  fi
}

create_and_activate_venv() {
  check_python_version

  if [ -n "$VIRTUAL_ENV" ]; then
    echo "⚠️  A virtual environment is already active: $VIRTUAL_ENV"
    echo "❌  Please deactivate it before running this script."
    exit 1
  fi

  if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment in $VENV_DIR..."
    python -m venv "$VENV_DIR"
  fi

  echo "Activating virtual environment..."
  # shellcheck source=/dev/null
  source "$VENV_DIR/Scripts/activate" 2>/dev/null || source "$VENV_DIR/bin/activate"
}

deactivate_venv() {
  echo "Deactivating virtual environment..."
  deactivate
}

get_latest_tag() {
  git ls-remote --tags https://github.com/robotframework/robotframework.git \
    | grep -o 'refs/tags/v[0-9.]*$' \
    | sed 's#refs/tags/##' \
    | sort -V \
    | tail -n 1
}

clone_rf() {
  if [ -d "$RF_DIR" ]; then
    echo "$RF_DIR already exists. Delete it with './run-robotframework-atests.sh clean' if needed."
  else
    LATEST_TAG=$(get_latest_tag)
    echo "Cloning Robot Framework at tag $LATEST_TAG..."
    git clone --branch "$LATEST_TAG" --depth 1 https://github.com/robotframework/robotframework.git "$RF_DIR"
  fi
}

install_rf() {
  clone_rf
  cd "$RF_DIR"
  pip install -e .
  pip install -r atest/requirements-run.txt
  pip install -r atest/requirements.txt
  cd ..
  # Install pabot
  pip install -e .
}

run_atests() {
  create_and_activate_venv
  trap deactivate_venv EXIT

  install_rf
  cd "$RF_DIR"
  python atest/run.py --processes 1
  echo "Results available in $RF_DIR/atest/results"
  cd ../..
}

clean() {
  rm -rf "$RF_DIR"
  rm -rf "$VENV_DIR"
}

case "$1" in
  run-atests|"")
    run_atests
    ;;
  install-rf)
    create_and_activate_venv
    install_rf
    deactivate_venv
    ;;
  clone-rf)
    clone_rf
    ;;
  clean)
    clean
    ;;
  *)
    echo "Usage: $0 [run-atests|install-rf|clone-rf|clean]"
    exit 1
    ;;
esac
