#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

compose_up() {
  docker compose -f "$ROOT_DIR/infra/docker-compose.base.yml" up -d
}

wait_kafka() {
  for i in {1..120}; do
    if docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "Kafka not ready"
  return 1
}

ensure_topic() {
  local topic="$1"
  local partitions="$2"
  docker exec kafka kafka-topics \
    --bootstrap-server localhost:9092 \
    --create --if-not-exists \
    --topic "$topic" \
    --partitions "$partitions" \
    --replication-factor 1 >/dev/null
}

assert_topic_partitions() {
  local topic="$1"
  local partitions="$2"
  docker exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic "$topic" \
    | grep -q "PartitionCount:${partitions}" \
    || { echo "FAIL: expected PartitionCount:${partitions} for topic=${topic}"; exit 1; }
}

produce_one() {
  local topic="$1"
  local msg="$2"
  echo "$msg" | docker exec -i kafka kafka-console-producer --bootstrap-server localhost:9092 --topic "$topic" >/dev/null
}

consume_one_contains() {
  local topic="$1"
  local needle="$2"

  docker exec kafka kafka-console-consumer \
    --bootstrap-server localhost:9092 \
    --topic "$topic" \
    --from-beginning \
    --timeout-ms 10000 \
    --max-messages 1 2>/dev/null \
    | grep -F "$needle" >/dev/null
}

main() {
  compose_up
  wait_kafka

  docker ps --format '{{.Names}}' | grep -q '^kafka$'
  docker ps --format '{{.Names}}' | grep -q '^zookeeper$'
  docker ps --format '{{.Names}}' | grep -q '^kafka-ui$'

  curl -fsS http://localhost:8080 >/dev/null

  ensure_topic bhf-demo 3
  assert_topic_partitions bhf-demo 3

  MSG="validate-bhf-$(date +%s)"
  produce_one bhf-demo "$MSG"
  consume_one_contains bhf-demo "$MSG"

  echo "OK"
}

main "$@"
