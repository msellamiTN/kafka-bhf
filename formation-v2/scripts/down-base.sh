#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/infra/docker-compose.base.yml"
PROJECT_NAME="bhf-kafka-base"

# Bring down the stack (even if it wasn't started with this project name)
docker compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" down -v --remove-orphans >/dev/null 2>&1 || true

# Defensive cleanup for fixed container names used by the training
docker rm -f kafka kafka-ui zookeeper >/dev/null 2>&1 || true
