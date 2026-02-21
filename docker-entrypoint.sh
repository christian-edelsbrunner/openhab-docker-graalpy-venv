#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

PYTHON_VENV_PATH=${PYTHON_VENV_PATH:-/openhab/userdata/cache/org.openhab.automation.pythonscripting/venv}
GRAALPY_BIN=${GRAALPY_HOME}/bin/graalpy

initialize_venv() {
  local venv_path=$1

  if [ -d "${venv_path}" ] && [ -x "${venv_path}/bin/python" ]; then
    echo "GraalPy venv already exists at ${venv_path}; skipping initialization"
    return
  fi

  echo "Initializing GraalPy venv at ${venv_path}"
  mkdir -p "${venv_path}"
  "${GRAALPY_BIN}" -m venv "${venv_path}"
  #chown -R openhab:openhab "${venv_path}"
  echo "GraalPy venv ready at ${venv_path}"
}

if [ -x "${GRAALPY_BIN}" ]; then
  initialize_venv "${PYTHON_VENV_PATH}"
else
  echo "Warning: GraalPy runtime missing at ${GRAALPY_BIN}, skipping venv creation"
fi

exec /entrypoint "$@"
