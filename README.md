# VPS Runbook (pmd + pmd_frontend)

This stack deploys the API + workers + scheduler + Postgres + Redis + Next.js dashboard behind Caddy with automatic TLS. Marketing stays on Vercel (no root domain on this VPS).

## 1) Prereqs
- A VPS with Docker Engine + Docker Compose v2 installed.
  - Ubuntu quick start:
    - curl -fsSL https://get.docker.com | sh
    - sudo usermod -aG docker $USER
- DNS A/AAAA records:
  - api.<your-domain> -> VPS public IP
  - app.<your-domain> -> VPS public IP
- Firewall: allow inbound 80/tcp and 443/tcp only.

## 2) Layout
Ensure these folders are siblings:
- pmd/
- pmd_frontend/
- pmd_infra/

## 3) Configure environment
From the VPS:
- cd pmd_infra
- cp env/prod.env.example .env
- Edit .env with your domains, secrets, and production values.

## 4) Deploy
Option A (recommended):
- ./scripts/deploy.sh

Option B (manual):
- docker compose -f compose.prod.yml --env-file .env up -d --build
- docker compose -f compose.prod.yml --env-file .env run --rm migrate

## 5) Update
- git pull (in pmd and pmd_frontend repos)
- cd pmd_infra
- ./scripts/deploy.sh

## 6) Logs and restarts
- docker compose -f compose.prod.yml --env-file .env logs -f --tail=200
- docker compose -f compose.prod.yml --env-file .env restart api

## 7) Backups
- ./scripts/backup.sh

Restore example:
- docker compose -f compose.prod.yml --env-file .env exec -T postgres \
  psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" < backups/your_backup.sql