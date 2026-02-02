#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NAMESPACE="kafka"

echo "=============================================="
echo "  Module 02 - Test APIs on K8s"
echo "=============================================="

# Get node IP (first IPv4 address only)
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null | awk '{print $1}')
if [ -z "$NODE_IP" ] || echo "$NODE_IP" | grep -q ":"; then
  # Fallback to hostname -I for IPv4
  NODE_IP=$(hostname -I | awk '{print $1}')
fi
if [ -z "$NODE_IP" ]; then
  NODE_IP="localhost"
fi

JAVA_API="http://${NODE_IP}:31080"
DOTNET_API="http://${NODE_IP}:31081"
TOXIPROXY_API="http://${NODE_IP}:31474"

ERRORS=0

echo ""
echo "🔍 Using Node IP: $NODE_IP"
echo ""

# Test health endpoints
echo "📋 Testing health endpoints..."
echo "-------------------------------------------"

echo -n "Java API health ($JAVA_API/health): "
if curl -fsS --max-time 5 "$JAVA_API/health" 2>/dev/null; then
  echo " ✅"
else
  echo " ❌ FAILED"
  ERRORS=$((ERRORS + 1))
fi

echo -n ".NET API health ($DOTNET_API/health): "
if curl -fsS --max-time 5 "$DOTNET_API/health" 2>/dev/null; then
  echo " ✅"
else
  echo " ❌ FAILED"
  ERRORS=$((ERRORS + 1))
fi

echo -n "Toxiproxy API ($TOXIPROXY_API/version): "
if curl -fsS --max-time 5 "$TOXIPROXY_API/version" 2>/dev/null; then
  echo " ✅"
else
  echo " ❌ FAILED"
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "📋 Testing message sending..."
echo "-------------------------------------------"

# Test Java API sync send
EVENT_JAVA="JAVA-K8S-TEST-$(date +%s)"
echo -n "Java API sync send (eventId=$EVENT_JAVA): "
JAVA_RESULT=$(curl -fsS --max-time 30 -X POST "$JAVA_API/api/v1/send?mode=idempotent&sendMode=sync&eventId=$EVENT_JAVA" 2>/dev/null || echo "FAILED")
if echo "$JAVA_RESULT" | grep -q "OK"; then
  echo "✅"
  echo "  Response: $JAVA_RESULT"
else
  echo "❌ FAILED"
  echo "  Response: $JAVA_RESULT"
  ERRORS=$((ERRORS + 1))
fi

# Test .NET API sync send
EVENT_DOTNET="DOTNET-K8S-TEST-$(date +%s)"
echo -n ".NET API sync send (eventId=$EVENT_DOTNET): "
DOTNET_RESULT=$(curl -fsS --max-time 30 -X POST "$DOTNET_API/api/v1/send?mode=idempotent&sendMode=sync&eventId=$EVENT_DOTNET" 2>/dev/null || echo "FAILED")
if echo "$DOTNET_RESULT" | grep -q "OK"; then
  echo "✅"
  echo "  Response: $DOTNET_RESULT"
else
  echo "❌ FAILED"
  echo "  Response: $DOTNET_RESULT"
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "=============================================="
if [ $ERRORS -eq 0 ]; then
  echo "  ✅ All API tests passed!"
else
  echo "  ❌ $ERRORS test(s) failed"
fi
echo "=============================================="

exit $ERRORS
