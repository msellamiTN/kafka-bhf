# Drills CLI (CCDAK) — Kafka en pratique

Objectif: automatiser les réflexes « examen + prod ».

## Règle

- **Tu dois être capable de taper ces commandes sans réfléchir**.
- Après chaque drill: note 1 chose apprise + 1 piège.

## Drill A — Topics (création / description)

Pré-requis: stack `docker/single-broker`.

- Lister:
  - `docker exec -it kafka kafka-topics --list --bootstrap-server localhost:9093`

- Créer:
  - `docker exec -it kafka kafka-topics --create --topic drill-a --bootstrap-server localhost:9093 --partitions 3 --replication-factor 1`

- Décrire:
  - `docker exec -it kafka kafka-topics --describe --topic drill-a --bootstrap-server localhost:9093`

## Drill B — Console producer avec clé

- `docker exec -it kafka kafka-console-producer --topic drill-a --bootstrap-server localhost:9093 --property parse.key=true --property key.separator=:`

- Envoyer:
  - `user1:hello`
  - `user1:again`
  - `user2:other`

## Drill C — Consumer group & lag

- Lancer un consumer group:
  - `docker exec -it kafka kafka-console-consumer --topic drill-a --bootstrap-server localhost:9093 --group drill-group --from-beginning`

- Dans un autre terminal:
  - `docker exec -it kafka kafka-consumer-groups --bootstrap-server localhost:9093 --group drill-group --describe`

## Drill D — Config topic (retention / compaction)

- Créer un topic compacté:
  - `docker exec -it kafka kafka-topics --create --topic drill-state --bootstrap-server localhost:9093 --partitions 3 --replication-factor 1 --config cleanup.policy=compact`

## Questions “exam style”

- Qu’est-ce qui influence l’ordre?
- Pourquoi `--from-beginning` change-t-il le comportement?
- Qu’est-ce que l’ISR et pourquoi c’est critique pour `acks=all`?
