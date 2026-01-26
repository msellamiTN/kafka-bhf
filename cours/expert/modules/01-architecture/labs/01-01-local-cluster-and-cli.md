# Lab 01.01 — Cluster local + CLI

## Objectif

- Démarrer un cluster local (Docker)
- Créer topics, partitions, observer la réplication

## Démarrer

- Single broker:
  - `docker compose -f docker/single-broker/docker-compose.yml up -d`

## Drills

```powershell
docker exec -it kafka kafka-topics --bootstrap-server localhost:9093 --create --topic expert01 --partitions 3 --replication-factor 1

docker exec -it kafka kafka-topics --bootstrap-server localhost:9093 --describe --topic expert01
```

## Checkpoint

1. Ordering garanti où?
2. À quoi sert ISR?
