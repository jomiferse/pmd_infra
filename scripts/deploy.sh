#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="${ROOT_DIR}/scripts"
COMPOSE_FILE="${COMPOSE_FILE:-${ROOT_DIR}/compose/compose.prod.yml}"
ENV_FILE="${ENV_FILE:-${ROOT_DIR}/.env}"

ENV_FILE="${ENV_FILE}" "${SCRIPTS_DIR}/preflight.sh"

echo "Pulling images..."
docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" pull
echo "Building images..."
docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" build --pull
echo "Starting services..."
docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" up -d --remove-orphans

ENV_FILE="${ENV_FILE}" COMPOSE_FILE="${COMPOSE_FILE}" "${SCRIPTS_DIR}/migrate.sh"
ENV_FILE="${ENV_FILE}" COMPOSE_FILE="${COMPOSE_FILE}" "${SCRIPTS_DIR}/smoke_prod.sh"

echo "Deploy complete."
