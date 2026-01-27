#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

docker compose -f "$ROOT_DIR/infra/docker-compose.base.yml" up -d
