# Kafka Expert Labs (Docker Compose)

This repo contains a **Docker Compose-based Kafka lab environment** aligned to the curriculum in `kafka-expert-labs.md`.

## Quick start

- Prerequisites
  - Docker Desktop + Docker Compose v2 (`docker compose`)

### Module 1 (single broker)

- Start:
  - `docker compose -f docker/single-broker/docker-compose.yml up -d`
- Kafka bootstrap (host): `localhost:9092`
- Kafka UI: `http://localhost:8080`

### Module 1 (single broker, KRaft / no ZooKeeper)

- Start:
  - `docker compose -f docker/kraft-single-broker/docker-compose.yml up -d`
- Kafka bootstrap (host): `localhost:9092`
- Kafka UI: `http://localhost:8080`

### Module 1 (multi broker)

- Start:
  - `docker compose -f docker/multi-broker/docker-compose.yml up -d`
- Brokers (host):
  - `localhost:9092`, `localhost:9093`, `localhost:9094`
- Kafka UI: `http://localhost:8080`

## Module-aligned stacks

- `docker/single-broker`
  - Modules: 1, 2, 4, 7, 9 (base runtime)
- `docker/multi-broker`
  - Modules: 1, 9, 13 (replication + ops exercises)
- `docker/schema-registry`
  - Modules: 3
- `docker/connect`
  - Modules: 5 (includes Connect + sample FileStream connectors)
- `docker/ksqldb`
  - Modules: 10
- `docker/monitoring`
  - Modules: 8 (Prometheus + Grafana + kafka-exporter)
- `docker/security`
  - Modules: 6 (SASL/PLAIN baseline + ACL-ready broker)
- `docker/multi-cluster`
  - Modules: 11 (two clusters + UI)

## Lab guides

See `labs/` for step-by-step lab entry points:

- `labs/module01-installation-first-messages.md`
- `labs/module03-schema-registry-avro.md`
- `labs/module05-kafka-connect.md`
- `labs/module06-security-sasl-acls.md`
- `labs/module08-monitoring.md`
- `labs/module10-ksqldb.md`
- `labs/module11-multi-cluster-mm2.md`

## Windows helper scripts

PowerShell scripts are provided under `scripts/`:

- `scripts/up.ps1 -ComposeFile <path>`
- `scripts/down.ps1 -ComposeFile <path>`
- `scripts/reset.ps1 -ComposeFile <path>`
- `scripts/health.ps1` (runs `kafka-broker-api-versions` inside the `kafka` container)

## Common commands

- Stop:
  - `docker compose -f <compose-file> down`
- Stop + delete volumes (full reset):
  - `docker compose -f <compose-file> down -v`

## Notes

- The Docker stacks are designed so you can run **one stack at a time** without port conflicts (except where explicitly documented).
- The curriculum document contains Java/Scala code labs; this repo focuses on providing the **Kafka platform** via Compose.
