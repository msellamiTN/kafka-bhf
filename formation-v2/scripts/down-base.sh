#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/infra/docker-compose.base.yml"
PROJECT_NAME="bhf-kafka-base"

# Bring down the stack
docker compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" down -v --remove-orphans

# Defensive cleanup for fixed container names
docker rm -f kafka kafka-ui portainer 2>/dev/null || true
