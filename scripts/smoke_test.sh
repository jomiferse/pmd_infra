#!/usr/bin/env bash
set -euo pipefail

EMAIL="${1:-${PMD_SMOKE_EMAIL:-}}"
PASSWORD="${2:-${PMD_SMOKE_PASSWORD:-}}"
if [[ -z "${EMAIL}" || -z "${PASSWORD}" ]]; then
  echo "Usage: $0 <email> <password>" >&2
  echo "Or set PMD_SMOKE_EMAIL and PMD_SMOKE_PASSWORD in the environment." >&2
  exit 1
fi

BASE_URL="${PMD_BASE_URL:-http://localhost:8000}"
COOKIE_JAR="$(mktemp -t pmd_smoke_cookie.XXXXXX)"
BODY_FILE="$(mktemp -t pmd_smoke_body.XXXXXX)"
trap 'rm -f "${COOKIE_JAR}" "${BODY_FILE}"' EXIT

echo "Logging in..."
LOGIN_STATUS=$(
  curl -sS -o "${BODY_FILE}" -w "%{http_code}" -c "${COOKIE_JAR}" \
    -H "Content-Type: application/json" \
    -X POST \
    -d "{\"email\":\"${EMAIL}\",\"password\":\"${PASSWORD}\"}" \
    "${BASE_URL%/}/auth/login"
)
if [[ "${LOGIN_STATUS}" != "200" ]]; then
  echo "Login failed (status ${LOGIN_STATUS})." >&2
  cat "${BODY_FILE}" >&2
  exit 1
fi

echo "Checking session..."
ME_STATUS=$(curl -sS -o "${BODY_FILE}" -w "%{http_code}" -b "${COOKIE_JAR}" "${BASE_URL%/}/me")
if [[ "${ME_STATUS}" != "200" ]]; then
  echo "/me failed (status ${ME_STATUS})." >&2
  cat "${BODY_FILE}" >&2
  exit 1
fi
if ! grep -q "\"telegram_pending\"" "${BODY_FILE}"; then
  echo "/me missing telegram status fields." >&2
  cat "${BODY_FILE}" >&2
  exit 1
fi

echo "Checking alerts..."
ALERTS_STATUS=$(curl -sS -o "${BODY_FILE}" -w "%{http_code}" -b "${COOKIE_JAR}" "${BASE_URL%/}/alerts/latest?limit=1")
if [[ "${ALERTS_STATUS}" != "200" ]]; then
  echo "/alerts/latest failed (status ${ALERTS_STATUS})." >&2
  cat "${BODY_FILE}" >&2
  exit 1
fi

echo "Checking copilot runs..."
COPILOT_STATUS=$(curl -sS -o "${BODY_FILE}" -w "%{http_code}" -b "${COOKIE_JAR}" "${BASE_URL%/}/copilot/runs?limit=1")
if [[ "${COPILOT_STATUS}" != "200" ]]; then
  echo "/copilot/runs failed (status ${COPILOT_STATUS})." >&2
  cat "${BODY_FILE}" >&2
  exit 1
fi

echo "Checking billing checkout..."
CHECKOUT_STATUS=$(
  curl -sS -o "${BODY_FILE}" -w "%{http_code}" -b "${COOKIE_JAR}" \
    -H "Content-Type: application/json" \
    -X POST \
    -d '{"plan_id":"basic"}' \
    "${BASE_URL%/}/billing/checkout-session"
)
if [[ "${CHECKOUT_STATUS}" != "200" && "${CHECKOUT_STATUS}" != "400" && "${CHECKOUT_STATUS}" != "409" && "${CHECKOUT_STATUS}" != "500" ]]; then
  echo "/billing/checkout-session unexpected status ${CHECKOUT_STATUS}." >&2
  cat "${BODY_FILE}" >&2
  exit 1
fi

echo "Checking billing portal..."
PORTAL_STATUS=$(
  curl -sS -o "${BODY_FILE}" -w "%{http_code}" -b "${COOKIE_JAR}" \
    -H "Content-Type: application/json" \
    -X POST \
    -d '{}' \
    "${BASE_URL%/}/billing/portal-session"
)
if [[ "${PORTAL_STATUS}" != "200" && "${PORTAL_STATUS}" != "400" && "${PORTAL_STATUS}" != "500" ]]; then
  echo "/billing/portal-session unexpected status ${PORTAL_STATUS}." >&2
  cat "${BODY_FILE}" >&2
  exit 1
fi

echo "Smoke checks OK."
