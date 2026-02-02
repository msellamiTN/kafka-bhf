#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
NAMESPACE="kafka"

echo "=============================================="
echo "  Module 02 - Validate K8s Deployment"
echo "=============================================="

ERRORS=0

echo ""
echo "📋 Checking pods status..."
echo "-------------------------------------------"

# Check Toxiproxy
TOXIPROXY_STATUS=$(kubectl get pods -n "$NAMESPACE" -l app=toxiproxy -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")
if [ "$TOXIPROXY_STATUS" = "Running" ]; then
  echo "✅ Toxiproxy: Running"
else
  echo "❌ Toxiproxy: $TOXIPROXY_STATUS"
  ERRORS=$((ERRORS + 1))
fi

# Check Java API
JAVA_STATUS=$(kubectl get pods -n "$NAMESPACE" -l app=m02-java-api -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")
if [ "$JAVA_STATUS" = "Running" ]; then
  echo "✅ Java API: Running"
else
  echo "❌ Java API: $JAVA_STATUS"
  ERRORS=$((ERRORS + 1))
fi

# Check .NET API
DOTNET_STATUS=$(kubectl get pods -n "$NAMESPACE" -l app=m02-dotnet-api -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")
if [ "$DOTNET_STATUS" = "Running" ]; then
  echo "✅ .NET API: Running"
else
  echo "❌ .NET API: $DOTNET_STATUS"
  ERRORS=$((ERRORS + 1))
fi

echo ""
echo "📋 Checking services..."
echo "-------------------------------------------"

# Check services
for svc in m02-java-api m02-dotnet-api toxiproxy; do
  if kubectl get svc "$svc" -n "$NAMESPACE" >/dev/null 2>&1; then
    NODEPORT=$(kubectl get svc "$svc" -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].nodePort}')
    echo "✅ Service $svc: NodePort $NODEPORT"
  else
    echo "❌ Service $svc: Not found"
    ERRORS=$((ERRORS + 1))
  fi
done

echo ""
echo "📋 Checking pod details..."
echo "-------------------------------------------"
kubectl get pods -n "$NAMESPACE" -l 'app in (m02-java-api,m02-dotnet-api,toxiproxy)' -o wide

echo ""
echo "📋 Checking service details..."
echo "-------------------------------------------"
kubectl get svc -n "$NAMESPACE" | grep -E "m02|toxiproxy" || true

echo ""
echo "=============================================="
if [ $ERRORS -eq 0 ]; then
  echo "  ✅ All validations passed!"
else
  echo "  ❌ $ERRORS validation(s) failed"
fi
echo "=============================================="
echo ""
echo "Next step: Run ./05-test-apis.sh to test the APIs"

exit $ERRORS
