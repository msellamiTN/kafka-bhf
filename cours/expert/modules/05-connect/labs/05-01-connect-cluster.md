# Lab 05.01 — Kafka Connect distributed cluster (démarrage + REST)

## Objectif

- Démarrer Kafka Connect en mode distributed
- Vérifier l’API REST
- Comprendre les topics internes `_connect-*`

## Pré-requis

- Stack: `docker/connect`

## Démarrer

- `docker compose -f docker/connect/docker-compose.yml up -d`

Endpoints:

- Connect REST: `http://localhost:8083`

## Vérifier REST

```powershell
curl http://localhost:8083/
curl http://localhost:8083/connectors
```

## Drill CLI

Lister les topics internes:

```powershell
docker exec -it kafka kafka-topics --list --bootstrap-server localhost:9093
```

## Suite

Pour aller plus loin, réutilise aussi les labs du parcours CCDAK:

- `cours/modules/05-connect/labs/05-01-deploiement-connect.md`
- `cours/modules/05-connect/labs/05-02-deployer-un-connector.md`
