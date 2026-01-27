# Lab 09.01 — Benchmark throughput (producer perf test)

## Objectif

- Mesurer le throughput producer
- Comparer compression / batching
- Comprendre les tradeoffs (latence vs débit)

## Pré-requis

- Stack: `docker/single-broker`

## Démarrer

- `docker compose -f docker/single-broker/docker-compose.yml up -d`

## Étape 1 — Créer un topic

```powershell
docker exec -it kafka kafka-topics --bootstrap-server localhost:9093 --create --topic perf01 --partitions 3 --replication-factor 1
```

## Étape 2 — Producer perf test (baseline)

```powershell
docker exec -it kafka kafka-producer-perf-test --topic perf01 --num-records 200000 --record-size 200 --throughput -1 --producer-props bootstrap.servers=localhost:9093 acks=all linger.ms=5 batch.size=32768 compression.type=none
```

## Étape 3 — Comparer compression

```powershell
docker exec -it kafka kafka-producer-perf-test --topic perf01 --num-records 200000 --record-size 200 --throughput -1 --producer-props bootstrap.servers=localhost:9093 acks=all linger.ms=5 batch.size=32768 compression.type=lz4
```

## Checkpoint

1. Pourquoi `linger.ms` peut augmenter le débit?
2. Quel impact de la compression sur CPU vs réseau?
