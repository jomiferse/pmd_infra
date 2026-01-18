#!/usr/bin/env bash
set -euo pipefail

API_KEY="${1:-${API_KEY:-}}"
if [[ -z "${API_KEY}" ]]; then
  echo "Usage: $0 <api_key>" >&2
  echo "Or set API_KEY in the environment." >&2
  exit 1
fi

BASE_URL="${PMD_BASE_URL:-http://localhost:8000}"

echo "Checking status..."
curl -sS -H "X-API-Key: ${API_KEY}" "${BASE_URL%/}/status"
echo

echo "Checking alerts summary..."
curl -sS -H "X-API-Key: ${API_KEY}" "${BASE_URL%/}/alerts/summary"
echo