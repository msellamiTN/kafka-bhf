#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=============================================="
echo "  Module 02 - Build Docker Images for K8s"
echo "=============================================="

cd "$MODULE_DIR"

echo ""
echo "📦 Building Java API image..."
docker build -t m02-java-api:latest -f java/Dockerfile java/
echo "✅ Java API image built successfully"

echo ""
echo "📦 Building .NET API image..."
docker build -t m02-dotnet-api:latest -f dotnet/Dockerfile dotnet/
echo "✅ .NET API image built successfully"

echo ""
echo "📋 Verifying images..."
docker images | grep -E "m02-(java|dotnet)-api" || true

echo ""
echo "=============================================="
echo "  ✅ All images built successfully!"
echo "=============================================="
echo ""
echo "Next step: Run ./02-import-images.sh to import images into K3s"
