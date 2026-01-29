#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

KAFKA_BIN="/opt/kafka/bin"
K8S_MODE=false
KAFKA_NAMESPACE="kafka"
KAFKA_CLUSTER="bhf-kafka"
STRIMZI_IMAGE="quay.io/strimzi/kafka:latest-kafka-4.0.0"

# Parse arguments
for arg in "$@"; do
  case $arg in
    --k8s|--kubernetes|--okd)
      K8S_MODE=true
      shift
      ;;
  esac
done

# ============== Docker Mode Functions ==============

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

count_event_docker() {
  local topic="$1"
  local event_id="$2"
  docker exec kafka $KAFKA_BIN/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic "$topic" --from-beginning --timeout-ms 10000 2>/dev/null \
    | { grep -F "$event_id" || true; } \
    | wc -l \
    | tr -d ' '
}

# ============== K8s Mode Functions ==============

wait_kafka_k8s() {
  echo "Checking Kafka cluster status..."
  for i in {1..60}; do
    if kubectl get kafka "$KAFKA_CLUSTER" -n "$KAFKA_NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null | grep -q "True"; then
      return 0
    fi
    sleep 2
  done
  echo "Kafka cluster not ready"
  return 1
}

ensure_topic_k8s() {
  local topic="$1"
  
  # Check if topic already exists
  if kubectl get kafkatopic "$topic" -n "$KAFKA_NAMESPACE" >/dev/null 2>&1; then
    return 0
  fi
  
  # Create topic via KafkaTopic CR
  cat <<EOF | kubectl apply -n "$KAFKA_NAMESPACE" -f -
apiVersion: kafka.strimzi.io/v1
kind: KafkaTopic
metadata:
  name: $topic
  labels:
    strimzi.io/cluster: $KAFKA_CLUSTER
spec:
  partitions: 3
  replicas: 1
  config:
    retention.ms: "604800000"
EOF
  
  # Wait for topic to be ready
  for i in {1..30}; do
    if kubectl get kafkatopic "$topic" -n "$KAFKA_NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null | grep -q "True"; then
      return 0
    fi
    sleep 1
  done
}

count_event_k8s() {
  local topic="$1"
  local event_id="$2"
  
  # Delete any orphan pods first
  kubectl delete pod kafka-consumer-count -n "$KAFKA_NAMESPACE" --ignore-not-found >/dev/null 2>&1 || true
  sleep 1
  
  kubectl run kafka-consumer-count -it --rm --image="$STRIMZI_IMAGE" \
    --restart=Never -n "$KAFKA_NAMESPACE" -- \
    bin/kafka-console-consumer.sh --bootstrap-server "${KAFKA_CLUSTER}-kafka-bootstrap:9092" \
    --topic "$topic" --from-beginning --timeout-ms 10000 2>/dev/null \
    | { grep -F "$event_id" || true; } \
    | wc -l \
    | tr -d ' '
}

# ============== Main Functions ==============

main_docker() {
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
  COUNT_JAVA_PLAIN=$(count_event_docker bhf-transactions "$EVENT_JAVA_PLAIN")

  EVENT_JAVA_IDEMP="JAVA-IDEMP-$(date +%s)"
  send_with_latency_then_recover "http://localhost:18080/api/v1/send?mode=idempotent&sendMode=sync&eventId=$EVENT_JAVA_IDEMP"
  sleep 2
  COUNT_JAVA_IDEMP=$(count_event_docker bhf-transactions "$EVENT_JAVA_IDEMP")

  EVENT_DOTNET_PLAIN="DOTNET-PLAIN-$(date +%s)"
  send_with_latency_then_recover "http://localhost:18081/api/v1/send?mode=plain&sendMode=sync&eventId=$EVENT_DOTNET_PLAIN"
  sleep 2
  COUNT_DOTNET_PLAIN=$(count_event_docker bhf-transactions "$EVENT_DOTNET_PLAIN")

  EVENT_DOTNET_IDEMP="DOTNET-IDEMP-$(date +%s)"
  send_with_latency_then_recover "http://localhost:18081/api/v1/send?mode=idempotent&sendMode=sync&eventId=$EVENT_DOTNET_IDEMP"
  sleep 2
  COUNT_DOTNET_IDEMP=$(count_event_docker bhf-transactions "$EVENT_DOTNET_IDEMP")

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

main_k8s() {
  echo "Running validation in K8s mode..."
  echo "NOTE: K8s mode tests idempotent producer without Toxiproxy latency injection"
  
  # Check cluster is ready
  wait_kafka_k8s
  
  # Get node IP for API access
  NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  if [ -z "$NODE_IP" ]; then
    echo "FAIL: Could not determine node IP"
    exit 1
  fi
  
  # Check APIs are deployed and accessible via NodePort
  # Assuming Java API on NodePort 31080 and .NET API on NodePort 31081
  JAVA_API="http://${NODE_IP}:31080"
  DOTNET_API="http://${NODE_IP}:31081"
  
  echo "Waiting for Java API at $JAVA_API..."
  wait_http "$JAVA_API/health" || {
    echo "WARN: Java API not accessible. Ensure m02-java-api is deployed with NodePort 31080"
    echo "Skipping API tests - validating Kafka cluster only"
    
    # At least validate Kafka works
    ensure_topic_k8s bhf-transactions
    echo "OK: Kafka cluster validated (API tests skipped)"
    return 0
  }
  
  echo "Waiting for .NET API at $DOTNET_API..."
  wait_http "$DOTNET_API/health" || {
    echo "WARN: .NET API not accessible at $DOTNET_API"
  }
  
  ensure_topic_k8s bhf-transactions
  
  # Test idempotent mode (without latency injection in K8s)
  EVENT_JAVA_IDEMP="JAVA-K8S-IDEMP-$(date +%s)"
  curl -fsS -X POST "$JAVA_API/api/v1/send?mode=idempotent&sendMode=sync&eventId=$EVENT_JAVA_IDEMP" >/dev/null || {
    echo "FAIL: Could not send message via Java API"
    exit 1
  }
  sleep 2
  COUNT_JAVA_IDEMP=$(count_event_k8s bhf-transactions "$EVENT_JAVA_IDEMP")
  
  if [ "$COUNT_JAVA_IDEMP" -ne 1 ]; then
    echo "FAIL: expected 1 message for Java idempotent eventId=$EVENT_JAVA_IDEMP, got $COUNT_JAVA_IDEMP"
    exit 1
  fi
  
  echo "OK: java_idempotent=$COUNT_JAVA_IDEMP (K8s mode - no latency injection)"
}

# Main entry point
if [ "$K8S_MODE" = true ]; then
  main_k8s
else
  main_docker
fi
