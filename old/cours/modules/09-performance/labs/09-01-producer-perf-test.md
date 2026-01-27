# Lab 09.01 — Producer perf test (CLI)

## Objectif

- Utiliser `kafka-producer-perf-test`
- Comparer compression et batching

## Démarrer

- `docker compose -f docker/single-broker/docker-compose.yml up -d`

## Créer un topic

```powershell
docker exec -it kafka kafka-topics --bootstrap-server localhost:9093 --create --topic perf-topic --partitions 3 --replication-factor 1
```

## Benchmark

```powershell
docker exec -it kafka kafka-producer-perf-test --topic perf-topic --num-records 100000 --record-size 200 --throughput -1 --producer-props bootstrap.servers=localhost:9093 acks=all linger.ms=5 batch.size=32768 compression.type=lz4
```

## Checkpoint

- Quelle config augmente le débit au prix de la latence?
