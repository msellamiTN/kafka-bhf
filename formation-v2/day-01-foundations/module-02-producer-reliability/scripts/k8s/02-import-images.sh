#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=============================================="
echo "  Module 02 - Import Images into K3s"
echo "=============================================="

cd "$MODULE_DIR"

echo ""
echo "📤 Exporting Java API image..."
sudo docker save m02-java-api:latest -o /tmp/m02-java-api.tar
echo "✅ Java API image exported"

echo ""
echo "📤 Exporting .NET API image..."
sudo docker save m02-dotnet-api:latest -o /tmp/m02-dotnet-api.tar
echo "✅ .NET API image exported"

echo ""
echo "📥 Importing Java API image into K3s containerd..."
sudo k3s ctr images import /tmp/m02-java-api.tar
echo "✅ Java API image imported"

echo ""
echo "📥 Importing .NET API image into K3s containerd..."
sudo k3s ctr images import /tmp/m02-dotnet-api.tar
echo "✅ .NET API image imported"

echo ""
echo "🧹 Cleaning up temporary files..."
rm -f /tmp/m02-java-api.tar /tmp/m02-dotnet-api.tar

echo ""
echo "📋 Verifying images in K3s..."
sudo k3s ctr images list | grep -E "m02-(java|dotnet)-api" || echo "⚠️ Images may be listed with docker.io/library/ prefix"

echo ""
echo "=============================================="
echo "  ✅ All images imported into K3s!"
echo "=============================================="
echo ""
echo "Next step: Run ./03-deploy.sh to deploy to Kubernetes"
