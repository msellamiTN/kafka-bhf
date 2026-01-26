# Lab 08.01 — Prometheus + Grafana (stack prête)

## Démarrer

- `docker compose -f docker/monitoring/docker-compose.yml up -d`

Endpoints:

- Kafka UI: `http://localhost:8080`
- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000` (admin/admin)

## Vérifier Prometheus

- Targets:
  - `http://localhost:9090/targets`

- Exporter:
  - `http://localhost:9308/metrics`

## Drill (lag)

1. Créer un topic + produire un lot.
2. Lancer un consumer lent (ou arrêter le consumer).
3. Constater l’augmentation du lag via:

```powershell
docker exec -it kafka kafka-consumer-groups --bootstrap-server localhost:9093 --describe --all-groups
```

## Checkpoint

- Citer 3 causes du lag.
- Quand un lag élevé est acceptable?

## Reset

- `docker compose -f docker/monitoring/docker-compose.yml down -v`
