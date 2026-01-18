# PMD Infra

## Overview
Docker and VPS deployment assets for the PMD backend and dashboard.
Includes compose stacks, Caddy config, and operational scripts.

## Quickstart
- Dev (local):

```bash
cp env/dev.env.example .env
./scripts/dev.sh
```

- Prod (VPS):

```bash
cp env/prod.env.example .env
./scripts/deploy.sh
```

## Configuration
- File map: `compose/compose.dev.yml`, `compose/compose.prod.yml`, `caddy/Caddyfile`, `env/dev.env.example`, `env/prod.env.example`, `scripts/`.
- DNS: `app.<domain>` and `api.<domain>` A/AAAA records to the VPS.
- Env files: copy the correct `env/*.env.example` to `.env` and update values.

## Links
- Troubleshooting: `docker compose -f compose/compose.prod.yml --env-file .env logs -f --tail=200`, `docker compose -f compose/compose.prod.yml --env-file .env restart api`, `curl https://api.<domain>/health`.
- Backups: `./scripts/backup_db.sh` (keeps last 7 by default).
- Status: `./scripts/status.sh`.
- Smoke tests: `./scripts/smoke_test.sh <email> <password>` (or set `PMD_SMOKE_EMAIL`/`PMD_SMOKE_PASSWORD`) for local/dev, `./scripts/smoke_prod.sh` for prod.
- Backend: `../pmd/README.md`
- Dashboard: `../pmd_frontend/README.md`
- Marketing: `../pmd_marketing/README.md`
