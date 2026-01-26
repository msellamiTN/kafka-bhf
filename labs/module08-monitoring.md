# Module 8: Monitoring & Observability (Docker)

## Goal

- Run Kafka with Prometheus + Grafana
- Visualize basic Kafka metrics

## Start stack

- `docker compose -f docker/monitoring/docker-compose.yml up -d`

Endpoints:

- Kafka (host): `localhost:9092`
- Kafka UI: `http://localhost:8080`
- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000` (admin/admin)

## Verify metrics

- Kafka exporter metrics:
  - `http://localhost:9308/metrics`

- Prometheus targets:
  - `http://localhost:9090/targets`

## Grafana

- Login:
  - User: `admin`
  - Password: `admin`

Notes:

- This stack provisions a Prometheus datasource automatically.
- If you want dashboards, import a Kafka exporter dashboard in Grafana and point it to the `Prometheus` datasource.

## Tear down

- `docker compose -f docker/monitoring/docker-compose.yml down -v`
