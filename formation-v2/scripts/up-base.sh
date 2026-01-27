#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/infra/docker-compose.base.yml"
PROJECT_NAME="bhf-kafka-base"

# Check for existing containers that would conflict
container_conflict() {
    local container=$1
    if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
        echo "Error: Container '${container}' already exists."
        echo "Run './scripts/down-base.sh' first to clean up, or remove it manually:"
        echo "  docker rm -f ${container}"
        exit 1
    fi
}

# Check for conflicts before starting
echo "Checking for existing containers..."
container_conflict "kafka"
container_conflict "kafka-ui"
container_conflict "portainer"

echo "Starting Kafka KRaft cluster..."
docker compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" up -d

echo "Waiting for services to be healthy..."
timeout 300 bash -c "
    until docker compose -p $PROJECT_NAME -f $COMPOSE_FILE ps --format json | jq -r '.State' | grep -q 'running' && \
          docker compose -p $PROJECT_NAME -f $COMPOSE_FILE ps --format json | jq -r '.Health' | grep -q 'healthy'; do
        echo 'Waiting for services...'; sleep 5; done
"

echo " Kafka KRaft cluster is ready!"
echo "Kafka UI: http://localhost:8080"
echo "Portainer: http://localhost:9443"
