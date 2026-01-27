#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

KAFKA_BIN="/opt/kafka/bin"

TOPIC="bhf-read-committed-demo-$(date +%s)"
GROUP_ID="m03-validate-$(date +%s)"

export KAFKA_TOPIC="$TOPIC"
export KAFKA_GROUP_ID_JAVA="${GROUP_ID}-java"
export KAFKA_GROUP_ID_DOTNET="${GROUP_ID}-dotnet"

compose_up() {
  docker compose -f "$ROOT_DIR/infra/docker-compose.single-node.yml" -f "$MODULE_DIR/docker-compose.module.yml" up -d --build
}

wait_http() {
  local url="$1"
  for i in {1..60}; do
    if curl -fsS "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

wait_kafka() {
  for i in {1..120}; do
    if docker exec kafka $KAFKA_BIN/kafka-topics.sh --bootstrap-server localhost:9092 --list >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "Kafka not ready"
  return 1
}

ensure_topic() {
  local topic="$1"
  docker exec kafka $KAFKA_BIN/kafka-topics.sh --bootstrap-server localhost:9092 --create --if-not-exists --topic "$topic" --partitions 3 --replication-factor 1 >/dev/null
}

wait_metrics_contains_only_committed() {
  local url="$1"
  local committed_id="$2"
  local aborted_id="$3"

  for i in {1..60}; do
    body="$(curl -fsS "$url" || true)"

    if echo "$body" | grep -F "\"processedCount\":1" >/dev/null 2>&1 \
      && echo "$body" | grep -F "\"$committed_id\"" >/dev/null 2>&1 \
      && ! echo "$body" | grep -F "\"$aborted_id\"" >/dev/null 2>&1; then
      return 0
    fi

    sleep 1
  done

  echo "FAIL: metrics did not converge for $url"
  echo "Expected committed=$committed_id visible and aborted=$aborted_id not visible"
  curl -fsS "$url" | cat || true
  return 1
}

main() {
  compose_up

  wait_kafka
  wait_http http://localhost:18090/health
  wait_http http://localhost:18091/health

  ensure_topic "$TOPIC"

  COMMITTED_ID="COMMITTED-$(date +%s)"
  ABORTED_ID="ABORTED-$(date +%s)"

  curl -fsS -X POST "http://localhost:18090/api/v1/tx/commit?txId=$COMMITTED_ID" >/dev/null
  curl -fsS -X POST "http://localhost:18090/api/v1/tx/abort?txId=$ABORTED_ID" >/dev/null

  wait_metrics_contains_only_committed "http://localhost:18090/api/v1/metrics" "$COMMITTED_ID" "$ABORTED_ID"
  wait_metrics_contains_only_committed "http://localhost:18091/api/v1/metrics" "$COMMITTED_ID" "$ABORTED_ID"

  echo "OK"
}

main "$@"
