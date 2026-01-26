# Lab 03.01 — Déployer Schema Registry + premiers appels API

## Objectif

- Démarrer Kafka + Schema Registry via Docker
- Valider l’API (`subjects`, `mode`)

## Démarrage

- `docker compose -f docker/schema-registry/docker-compose.yml up -d`

Endpoints:

- Kafka (host): `localhost:9092`
- Schema Registry: `http://localhost:8081`
- Kafka UI: `http://localhost:8080`

## Vérifications (API)

- Subjects:

```powershell
curl http://localhost:8081/subjects
```

- Mode:

```powershell
curl http://localhost:8081/mode
```

Attendu:

- liste vide `[]`
- mode `READWRITE`

## Drill CLI (bonus)

- Lister les topics Kafka:

```powershell
docker exec -it kafka kafka-topics --list --bootstrap-server localhost:9093
```

## Reset

- `docker compose -f docker/schema-registry/docker-compose.yml down -v`
