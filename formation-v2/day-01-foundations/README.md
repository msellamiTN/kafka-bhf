# Day 01 - Fondamentaux (V2)

Chaque module est **auto-rythmé** et déployé via **Docker** avec KRaft (sans ZooKeeper).

## Prérequis

- Docker + Docker Compose plugin (`docker compose`)
- Scripts exécutables : `chmod +x ./scripts/*.sh`

## Démarrage

```bash
# Mode nœud unique (recommandé pour la formation)
./scripts/start.sh

# Ou explicitement
./scripts/start.sh single-node

# Mode cluster (3 nœuds)
./scripts/start.sh cluster
```

- Kafka UI: <http://localhost:8080>
- Portainer: <http://localhost:9443>

## Arrêt

```bash
# Arrêter le mode utilisé
./scripts/stop.sh

# Ou explicitement
./scripts/stop.sh single-node
./scripts/stop.sh cluster
```

## Modules

- [Module 01 - Architecture du Cluster](./module-01-cluster/README.md)
- [Module 02 - Fiabilité du Producteur](./module-02-producer-reliability/README.md)
- [Module 03 - Consommateur Read-Committed](./module-03-consumer-read-committed/README.md)

## Configuration KRaft

Les modules utilisent la configuration KRaft avec l'image officielle `apache/kafka:latest` :

- **Single node** : 1 broker (broker + contrôleur)
- **Cluster** : 3 brokers (chaque broker + contrôleur)
- **Pas de ZooKeeper** : Métadonnées gérées en interne par Kafka
- **Ports** : Kafka 9092 (+9093,9094 pour cluster), UI 8080

Consultez `../infra/README.md` pour plus de détails sur les options de déploiement.
