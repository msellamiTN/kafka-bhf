#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
K8S_DIR="$MODULE_DIR/k8s"
NAMESPACE="kafka"

echo "=============================================="
echo "  Module 02 - Cleanup K8s Resources"
echo "=============================================="

echo ""
echo "🗑️ Deleting deployments..."
kubectl delete deployment m02-java-api -n "$NAMESPACE" --ignore-not-found
kubectl delete deployment m02-dotnet-api -n "$NAMESPACE" --ignore-not-found
kubectl delete deployment toxiproxy -n "$NAMESPACE" --ignore-not-found

echo ""
echo "🗑️ Deleting jobs..."
kubectl delete job toxiproxy-init -n "$NAMESPACE" --ignore-not-found

echo ""
echo "🗑️ Deleting services..."
kubectl delete service m02-java-api -n "$NAMESPACE" --ignore-not-found
kubectl delete service m02-dotnet-api -n "$NAMESPACE" --ignore-not-found
kubectl delete service toxiproxy -n "$NAMESPACE" --ignore-not-found

echo ""
echo "📋 Remaining pods in namespace..."
kubectl get pods -n "$NAMESPACE" | grep -E "m02|toxiproxy" || echo "No module-02 pods found"

echo ""
echo "=============================================="
echo "  ✅ Cleanup complete!"
echo "=============================================="
