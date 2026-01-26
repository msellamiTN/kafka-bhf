# Lab 03.01 — Manual commit + rebalancing

## Objectif

- Implémenter un commit manuel après traitement
- Provoquer un rebalance (2 consumers) et observer l’impact

## Démarrer

- `docker compose -f docker/single-broker/docker-compose.yml up -d`

## Drill CLI

```powershell
docker exec -it kafka kafka-consumer-groups --bootstrap-server localhost:9093 --describe --all-groups
```

## Checkpoint

- Qu’est-ce qui déclenche un rebalance?
