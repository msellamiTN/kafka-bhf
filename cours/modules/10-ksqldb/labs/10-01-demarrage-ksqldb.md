# Lab 10.01 — Démarrer ksqlDB + CLI

## Démarrer

- `docker compose -f docker/ksqldb/docker-compose.yml up -d`

Endpoints:

- ksqlDB REST: `http://localhost:8088`
- Kafka UI: `http://localhost:8080`

## Ouvrir le CLI ksql

```powershell
docker exec -it ksqldb-cli ksql http://ksqldb-server:8088
```

Dans le prompt:

- `SHOW TOPICS;`
- `SHOW STREAMS;`

## Checkpoint

- Différence STREAM vs TABLE?

## Reset

- `docker compose -f docker/ksqldb/docker-compose.yml down -v`
