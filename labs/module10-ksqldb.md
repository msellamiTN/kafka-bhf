# Module 10: ksqlDB (Docker)

## Goal

- Run ksqlDB server + CLI
- Execute simple ksqlDB statements

## Start stack

- `docker compose -f docker/ksqldb/docker-compose.yml up -d`

Endpoints:

- Kafka (host): `localhost:9092`
- Schema Registry: `http://localhost:8081`
- ksqlDB REST: `http://localhost:8088`
- Kafka UI: `http://localhost:8080`

## Open the ksqlDB CLI

- `docker exec -it ksqldb-cli ksql http://ksqldb-server:8088`

## Minimal smoke test

In the ksql prompt:

- `SHOW TOPICS;`
- `SHOW STREAMS;`

## Tear down

- `docker compose -f docker/ksqldb/docker-compose.yml down -v`
