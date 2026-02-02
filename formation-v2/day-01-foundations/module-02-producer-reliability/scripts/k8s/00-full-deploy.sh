#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=============================================="
echo "  Module 02 - Full K8s Deployment Pipeline"
echo "=============================================="
echo ""
echo "This script will run all steps in sequence:"
echo "  1. Build Docker images"
echo "  2. Import images into K3s"
echo "  3. Deploy to Kubernetes"
echo "  4. Validate deployment"
echo "  5. Test APIs"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

echo ""
echo "Step 1/5: Building images..."
echo "=============================================="
"$SCRIPT_DIR/01-build-images.sh"

echo ""
echo "Step 2/5: Importing images into K3s..."
echo "=============================================="
"$SCRIPT_DIR/02-import-images.sh"

echo ""
echo "Step 3/5: Deploying to Kubernetes..."
echo "=============================================="
"$SCRIPT_DIR/03-deploy.sh"

echo ""
echo "Step 4/5: Validating deployment..."
echo "=============================================="
"$SCRIPT_DIR/04-validate.sh"

echo ""
echo "Step 5/5: Testing APIs..."
echo "=============================================="
"$SCRIPT_DIR/05-test-apis.sh"

echo ""
echo "=============================================="
echo "  ✅ Full deployment pipeline complete!"
echo "=============================================="
echo ""
echo "Services available at:"
echo "  - Java API:    http://localhost:31080"
echo "  - .NET API:    http://localhost:31081"
echo "  - Toxiproxy:   http://localhost:31474"
echo ""
echo "To cleanup: ./06-cleanup.sh"
