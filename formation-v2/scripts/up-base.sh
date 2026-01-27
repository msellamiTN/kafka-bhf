#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/infra/docker-compose.base.yml"
PROJECT_NAME="bhf-kafka-base"

container_conflict() {
  local name="$1"
  if docker ps -a --format '{{.Names}}' | grep -qx "$name"; then
    local project
    project="$(docker inspect -f '{{ index .Config.Labels "com.docker.compose.project" }}' "$name" 2>/dev/null || true)"

    echo "ERROR: container name '$name' already exists and blocks startup."
    if [ -n "$project" ] && [ "$project" != "$PROJECT_NAME" ]; then
      echo "It belongs to another compose project: '$project'"
    fi
    echo "Fix: sudo docker rm -f $name"
    echo "Or:  sudo ./scripts/down-base.sh"
    exit 1
  fi
}

container_conflict kafka-ui
container_conflict kafka
container_conflict zookeeper
container_conflict portainer

docker compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" up -d
