# Lab 10.01 — Monitoring: Prometheus + Grafana

## Objectif

- Démarrer la stack de monitoring
- Vérifier le scraping Prometheus
- Lire des métriques utiles (lag, broker health)

## Pré-requis

- Stack: `docker/monitoring`

## Démarrer

- `docker compose -f docker/monitoring/docker-compose.yml up -d`

Endpoints:

- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000` (admin/admin)

## Vérifier

- Targets:
  - `http://localhost:9090/targets`

## Référence interne

- Lab CCDAK observabilité:
  - `cours/modules/08-observabilite/labs/08-01-prometheus-grafana.md`
