#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.test.yml"
COMPOSE_CMD=()

invoke_compose() {
  "${COMPOSE_CMD[@]}" "$@"
}

select_compose_tool() {
  local candidate candidate_parts

  if [[ -n "${COMPOSE_TOOL:-}" ]]; then
    read -ra candidate_parts <<< "$COMPOSE_TOOL"
    if ! command -v "${candidate_parts[0]}" >/dev/null 2>&1; then
      echo "Custom compose tool '${candidate_parts[0]}' is not in PATH." >&2
      return 1
    fi
    if "${candidate_parts[@]}" version >/dev/null 2>&1; then
      COMPOSE_CMD=("${candidate_parts[@]}")
      echo "Using compose tool: ${candidate_parts[*]}"
      return 0
    fi
    echo "${candidate_parts[*]} cannot execute 'version'." >&2
    return 1
  fi

  for candidate in "docker compose" "podman compose" "podman-compose"; do
    read -ra candidate_parts <<< "$candidate"
    if command -v "${candidate_parts[0]}" >/dev/null 2>&1 && "${candidate_parts[@]}" version >/dev/null 2>&1; then
      COMPOSE_CMD=("${candidate_parts[@]}")
      echo "Using compose tool: ${candidate_parts[*]}"
      return 0
    fi
  done

  echo "No compatible compose plugin found (docker compose, podman compose, or podman-compose)." >&2
  return 1
}

cleanup() {
  echo "Tearing down test stack..."
  invoke_compose -f "$COMPOSE_FILE" down --volumes --remove-orphans >/dev/null
}

select_compose_tool || {
  echo "Please install docker compose, podman compose, or podman-compose." >&2
  exit 1
}

trap cleanup EXIT

echo "Building and starting OpenHAB stack..."
invoke_compose -f "$COMPOSE_FILE" up --build -d

echo "Running Test script..."
"$SCRIPT_DIR/tests/check_venv.py"
echo "Smoke test completed successfully."

