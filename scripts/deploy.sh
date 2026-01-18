#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="${COMPOSE_FILE:-${ROOT_DIR}/compose/compose.prod.yml}"
ENV_FILE="${ENV_FILE:-${ROOT_DIR}/.env}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}" >&2
  exit 1
fi

docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" pull
docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" build --pull
docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" up -d --remove-orphans

docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" run --rm migrate

set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a

if [[ -z "${NEXT_PUBLIC_API_BASE_URL:-}" || -z "${APP_URL:-}" ]]; then
  echo "NEXT_PUBLIC_API_BASE_URL and APP_URL must be set for health checks." >&2
  exit 1
fi

echo "Checking API health..."
curl -fsS "${NEXT_PUBLIC_API_BASE_URL%/}/health" >/dev/null

echo "Checking frontend..."
curl -fsS "${APP_URL%/}/" >/dev/null

echo "Deploy complete."
