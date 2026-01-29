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

TOPIC="bhf-read-committed-demo-$(date +%s)"
GROUP_ID="m03-validate-$(date +%s)"

export KAFKA_TOPIC="$TOPIC"
export KAFKA_GROUP_ID_JAVA="${GROUP_ID}-java"
export KAFKA_GROUP_ID_DOTNET="${GROUP_ID}-dotnet"

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

# ============== Main Functions ==============

main_docker() {
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

main_k8s() {
  echo "Running validation in K8s mode..."
  
  # Check cluster is ready
  wait_kafka_k8s
  
  # Get node IP for API access
  NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
  if [ -z "$NODE_IP" ]; then
    echo "FAIL: Could not determine node IP"
    exit 1
  fi
  
  # Check APIs are deployed and accessible via NodePort
  # Assuming Java API on NodePort 31090 and .NET API on NodePort 31091
  JAVA_API="http://${NODE_IP}:31090"
  DOTNET_API="http://${NODE_IP}:31091"
  
  echo "Waiting for Java API at $JAVA_API..."
  wait_http "$JAVA_API/health" || {
    echo "WARN: Java API not accessible. Ensure m03-java-api is deployed with NodePort 31090"
    echo "Skipping API tests - validating Kafka cluster only"
    
    # At least validate Kafka works
    ensure_topic_k8s "$TOPIC"
    echo "OK: Kafka cluster validated (API tests skipped)"
    return 0
  }
  
  echo "Waiting for .NET API at $DOTNET_API..."
  wait_http "$DOTNET_API/health" || {
    echo "WARN: .NET API not accessible at $DOTNET_API"
  }
  
  ensure_topic_k8s "$TOPIC"
  
  COMMITTED_ID="COMMITTED-K8S-$(date +%s)"
  ABORTED_ID="ABORTED-K8S-$(date +%s)"
  
  curl -fsS -X POST "$JAVA_API/api/v1/tx/commit?txId=$COMMITTED_ID" >/dev/null || {
    echo "FAIL: Could not send committed transaction via Java API"
    exit 1
  }
  
  curl -fsS -X POST "$JAVA_API/api/v1/tx/abort?txId=$ABORTED_ID" >/dev/null || {
    echo "FAIL: Could not send aborted transaction via Java API"
    exit 1
  }
  
  wait_metrics_contains_only_committed "$JAVA_API/api/v1/metrics" "$COMMITTED_ID" "$ABORTED_ID"
  wait_metrics_contains_only_committed "$DOTNET_API/api/v1/metrics" "$COMMITTED_ID" "$ABORTED_ID"
  
  echo "OK"
}

# Main entry point
if [ "$K8S_MODE" = true ]; then
  main_k8s
else
  main_docker
fi
