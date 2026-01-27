# Lab 01.01 — Lancer un cluster Kafka local + drills CLI

## Objectif

- Lancer un cluster Kafka local via Docker Compose
- Exécuter les commandes fondamentales attendues au CCDAK

## Pré-requis

- Docker Desktop
- Ce repo cloné

## Choix du runtime

- Option 1 (recommandée pour débuter): **ZooKeeper single-broker**
  - `docker/single-broker/docker-compose.yml`

- Option 2 (pour comprendre Kafka moderne): **KRaft single-broker**
  - `docker/kraft-single-broker/docker-compose.yml`

## Étape 1 — Démarrer la stack

### ZooKeeper (single broker)

- Démarrer:
  - `docker compose -f docker/single-broker/docker-compose.yml up -d`

### KRaft (single broker)

- Démarrer:
  - `docker compose -f docker/kraft-single-broker/docker-compose.yml up -d`

## Étape 2 — Vérifier que Kafka répond

- Méthode A (simple): Kafka UI
  - `http://localhost:8080`

- Méthode B (CLI): API versions
  - ZooKeeper stack:
    - `docker exec -it kafka kafka-broker-api-versions --bootstrap-server localhost:9093`

## Étape 3 — Drills CLI (à répéter)

### Drill 3.1 — Créer un topic "drill-topic"

- `docker exec -it kafka kafka-topics --create --topic drill-topic --bootstrap-server localhost:9093 --partitions 3 --replication-factor 1`

### Drill 3.2 — Décrire et interpréter

- `docker exec -it kafka kafka-topics --describe --topic drill-topic --bootstrap-server localhost:9093`

Ce que tu dois savoir lire:

- **Leader** (broker qui sert la partition)
- **Replicas** (copies)
- **ISR** (in-sync replicas)

### Drill 3.3 — Produire avec clés

- `docker exec -it kafka kafka-console-producer --topic drill-topic --bootstrap-server localhost:9093 --property parse.key=true --property key.separator=:`

Envoyer:

- `user1:login`
- `user1:purchase`
- `user2:logout`

### Drill 3.4 — Consommer + métadonnées

- `docker exec -it kafka kafka-console-consumer --topic drill-topic --bootstrap-server localhost:9093 --from-beginning --property print.key=true --property print.partition=true --property print.offset=true`

### Drill 3.5 — Consumer groups

- Terminal A:
  - `docker exec -it kafka kafka-console-consumer --topic drill-topic --bootstrap-server localhost:9093 --group drill-group --from-beginning`

- Terminal B:
  - `docker exec -it kafka kafka-consumer-groups --bootstrap-server localhost:9093 --group drill-group --describe`

## Exercice noté (mini)

Créer un topic `transactions` avec:

- 12 partitions
- retention 7 jours
- compaction activée

Indice:

- `--config retention.ms=604800000`
- `--config cleanup.policy=compact,delete`

## Checkpoint (questions)

1. Pourquoi l’ordre est-il garanti seulement dans une partition?
2. Quel est l’impact d’une clé nulle?
3. À quoi sert l’ISR et quel lien avec `acks=all`?

## Reset

- Stop:
  - `docker compose -f docker/single-broker/docker-compose.yml down`

- Reset total:
  - `docker compose -f docker/single-broker/docker-compose.yml down -v`
