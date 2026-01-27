#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

KAFKA_BIN="/opt/kafka/bin"

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

toxi_api() {
  curl -fsS -H 'Content-Type: application/json' "$@"
}

setup_proxy() {
  toxi_api -X POST http://localhost:8474/proxies -d '{"name":"kafka","listen":"0.0.0.0:29093","upstream":"kafka:29092"}' >/dev/null || true
}

add_latency() {
  toxi_api -X POST http://localhost:8474/proxies/kafka/toxics -d '{"name":"latency","type":"latency","stream":"downstream","attributes":{"latency":5000,"jitter":0}}' >/dev/null || true
}

remove_latency() {
  curl -fsS -X DELETE http://localhost:8474/proxies/kafka/toxics/latency >/dev/null 2>&1 || true
}

send_with_latency_then_recover() {
  local url="$1"

  add_latency
  curl -fsS -X POST --max-time 120 "$url" >/dev/null &
  local pid="$!"

  sleep 2
  remove_latency

  wait "$pid"
}

count_event() {
  local topic="$1"
  local event_id="$2"
  docker exec kafka $KAFKA_BIN/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic "$topic" --from-beginning --timeout-ms 10000 2>/dev/null \
    | { grep -F "$event_id" || true; } \
    | wc -l \
    | tr -d ' '
}

main() {
  compose_up

  wait_kafka

  wait_http http://localhost:18080/health
  wait_http http://localhost:18081/health
  wait_http http://localhost:8474/version

  ensure_topic bhf-transactions

  setup_proxy

  EVENT_JAVA_PLAIN="JAVA-PLAIN-$(date +%s)"
  send_with_latency_then_recover "http://localhost:18080/api/v1/send?mode=plain&sendMode=sync&eventId=$EVENT_JAVA_PLAIN"
  sleep 2
  COUNT_JAVA_PLAIN=$(count_event bhf-transactions "$EVENT_JAVA_PLAIN")

  EVENT_JAVA_IDEMP="JAVA-IDEMP-$(date +%s)"
  send_with_latency_then_recover "http://localhost:18080/api/v1/send?mode=idempotent&sendMode=sync&eventId=$EVENT_JAVA_IDEMP"
  sleep 2
  COUNT_JAVA_IDEMP=$(count_event bhf-transactions "$EVENT_JAVA_IDEMP")

  EVENT_DOTNET_PLAIN="DOTNET-PLAIN-$(date +%s)"
  send_with_latency_then_recover "http://localhost:18081/api/v1/send?mode=plain&sendMode=sync&eventId=$EVENT_DOTNET_PLAIN"
  sleep 2
  COUNT_DOTNET_PLAIN=$(count_event bhf-transactions "$EVENT_DOTNET_PLAIN")

  EVENT_DOTNET_IDEMP="DOTNET-IDEMP-$(date +%s)"
  send_with_latency_then_recover "http://localhost:18081/api/v1/send?mode=idempotent&sendMode=sync&eventId=$EVENT_DOTNET_IDEMP"
  sleep 2
  COUNT_DOTNET_IDEMP=$(count_event bhf-transactions "$EVENT_DOTNET_IDEMP")

  if [ "$COUNT_JAVA_IDEMP" -ne 1 ]; then
    echo "FAIL: expected 1 message for Java idempotent eventId=$EVENT_JAVA_IDEMP, got $COUNT_JAVA_IDEMP"
    exit 1
  fi

  if [ "$COUNT_DOTNET_IDEMP" -ne 1 ]; then
    echo "FAIL: expected 1 message for .NET idempotent eventId=$EVENT_DOTNET_IDEMP, got $COUNT_DOTNET_IDEMP"
    exit 1
  fi

  if [ "$COUNT_JAVA_PLAIN" -le 1 ]; then
    echo "WARN: Java plain producer did not duplicate (count=$COUNT_JAVA_PLAIN). This can happen depending on timing."
  fi

  if [ "$COUNT_DOTNET_PLAIN" -le 1 ]; then
    echo "WARN: .NET plain producer did not duplicate (count=$COUNT_DOTNET_PLAIN). This can happen depending on timing."
  fi

  echo "OK: java_idempotent=$COUNT_JAVA_IDEMP java_plain=$COUNT_JAVA_PLAIN dotnet_idempotent=$COUNT_DOTNET_IDEMP dotnet_plain=$COUNT_DOTNET_PLAIN"
}

main "$@"
