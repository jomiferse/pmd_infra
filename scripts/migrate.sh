#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="${COMPOSE_FILE:-${ROOT_DIR}/compose/compose.prod.yml}"
ENV_FILE="${ENV_FILE:-${ROOT_DIR}/.env}"
ENV_EXAMPLE="${ENV_EXAMPLE:-${ROOT_DIR}/env/prod.env.example}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}" >&2
  if [[ -f "${ENV_EXAMPLE}" ]]; then
    echo "Copy ${ENV_EXAMPLE} to ${ENV_FILE} and update values." >&2
  fi
  exit 1
fi

echo "Running migrations..."
docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" run --rm migrate