# Lab 02.01 — Producer: CLI vs Java (comparatif + bonnes configs)

## Objectif

- Comparer un envoi via `kafka-console-producer` et via un producer Java
- Comprendre *ce que change* la configuration (acks, retries, idempotence)

## Pré-requis

- Stack: `docker/single-broker/docker-compose.yml`

Démarrer:

- `docker compose -f docker/single-broker/docker-compose.yml up -d`

## Étape 1 — Préparer le topic

- `docker exec -it kafka kafka-topics --create --topic lab02-events --bootstrap-server localhost:9093 --partitions 3 --replication-factor 1`

## Étape 2 — Envoi via CLI

- Producer (avec clé):

- `docker exec -it kafka kafka-console-producer --topic lab02-events --bootstrap-server localhost:9093 --property parse.key=true --property key.separator=:`

Envoie 10 lignes:

- `user-1:click`
- `user-1:buy`
- `user-2:click`

## Étape 3 — Observer côté consumer

- `docker exec -it kafka kafka-console-consumer --topic lab02-events --bootstrap-server localhost:9093 --from-beginning --property print.key=true --property print.partition=true --property print.offset=true`

## Étape 4 — Envoi via Java (à faire)

Dans le mini-projet Java du cours (créé dans le *book* Spring plus loin), implémente un producer qui:

- utilise `acks=all`
- active `enable.idempotence=true`
- respecte `max.in.flight.requests.per.connection<=5`
- fixe `retries` (ex: 3)
- logge `RecordMetadata`

Notes:

- L’idempotence vise à éviter les doublons lors des retries, mais **ce n’est pas** de l’exactly-once “end-to-end”.
- L’ordering est garanti **dans une partition**. La contrainte `max.in.flight...<=5` évite des réordonnancements dangereux lors des retries.

## CLI drills (5 minutes)

- Lister le topic:
  - `docker exec -it kafka kafka-topics --describe --topic lab02-events --bootstrap-server localhost:9093`

- Expliquer:
  - pourquoi les messages d’un même `key` vont au même partition.

## Checkpoint (exam style)

1. Pourquoi `enable.idempotence=true` réduit les doublons?
2. Dans quels cas `acks=1` est acceptable?
3. Quelle est la différence entre ordering et exactly-once?
