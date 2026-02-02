#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
K8S_DIR="$MODULE_DIR/k8s"
NAMESPACE="kafka"

echo "=============================================="
echo "  Module 02 - Deploy to Kubernetes"
echo "=============================================="

echo ""
echo "📋 Checking namespace..."
kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || {
  echo "Creating namespace $NAMESPACE..."
  kubectl create namespace "$NAMESPACE"
}

echo ""
echo "🗑️ Cleaning up existing deployments..."
kubectl delete deployment m02-java-api -n "$NAMESPACE" --ignore-not-found
kubectl delete deployment m02-dotnet-api -n "$NAMESPACE" --ignore-not-found
kubectl delete deployment toxiproxy -n "$NAMESPACE" --ignore-not-found
kubectl delete job toxiproxy-init -n "$NAMESPACE" --ignore-not-found
echo "✅ Cleanup complete"

echo ""
echo "🚀 Deploying Toxiproxy..."
kubectl apply -f "$K8S_DIR/toxiproxy.yaml"

echo ""
echo "⏳ Waiting for Toxiproxy to be ready..."
kubectl wait --for=condition=ready pod -l app=toxiproxy -n "$NAMESPACE" --timeout=120s || {
  echo "⚠️ Toxiproxy not ready yet, continuing..."
}

echo ""
echo "🔧 Running Toxiproxy init job..."
kubectl apply -f "$K8S_DIR/toxiproxy-init.yaml"

echo ""
echo "🚀 Deploying Java API..."
kubectl apply -f "$K8S_DIR/m02-java-api.yaml"

echo ""
echo "🚀 Deploying .NET API..."
kubectl apply -f "$K8S_DIR/m02-dotnet-api.yaml"

echo ""
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available deployment/m02-java-api -n "$NAMESPACE" --timeout=120s || {
  echo "⚠️ Java API deployment not ready"
}
kubectl wait --for=condition=available deployment/m02-dotnet-api -n "$NAMESPACE" --timeout=120s || {
  echo "⚠️ .NET API deployment not ready"
}

echo ""
echo "=============================================="
echo "  ✅ Deployment complete!"
echo "=============================================="
echo ""
echo "Next step: Run ./04-validate.sh to validate the deployment"
