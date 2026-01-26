# Lab 05.01 — Démarrer Kafka Connect + vérifications

## Démarrage

- `docker compose -f docker/connect/docker-compose.yml up -d`

Endpoints:

- Kafka (host): `localhost:9092`
- Connect REST: `http://localhost:8083`
- Kafka UI: `http://localhost:8080`

## Vérifier l’API REST

```powershell
curl http://localhost:8083/
curl http://localhost:8083/connectors
```

## Drill CLI

Lister les topics internes:

```powershell
docker exec -it kafka kafka-topics --list --bootstrap-server localhost:9093
```

Tu dois repérer:

- `_connect-configs`
- `_connect-offsets`
- `_connect-status`
