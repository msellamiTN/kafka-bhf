# Lab 07.01 — Idempotent Producer (socle anti-doublons)

## Objectif

- Comprendre la promesse de `enable.idempotence=true`
- Connaître les **contraintes obligatoires** associées

## Rappel (cornerstone)

Quand l’idempotence est activée:

- `enable.idempotence=true`
- `acks=all`
- `max.in.flight.requests.per.connection<=5`

## Pré-requis

- Stack: `docker/single-broker`

## Étapes

1. Démarrer Kafka:

   - `docker compose -f docker/single-broker/docker-compose.yml up -d`

1. Créer un topic:

```powershell
docker exec -it kafka kafka-topics --bootstrap-server localhost:9093 --create --topic expert07-idem --partitions 3 --replication-factor 1
```

1. Lancer le producer idempotent (runnable)

Depuis `book-spring-microservices/code`:

```powershell
mvn -pl kafka-labs -Dexec.mainClass=com.data2ai.kafkacourse.labs.producer.IdempotentProducerApp exec:java -Dexec.args="expert07-idem localhost:9092 50"
```

1. Vérifier la réception

```powershell
docker exec -it kafka kafka-console-consumer --bootstrap-server localhost:9093 --topic expert07-idem --from-beginning --property print.key=true --property print.partition=true --property print.offset=true
```

## Checkpoint (exam style)

1. Pourquoi `acks=all` est requis?
1. Pourquoi `max.in.flight...<=5`?
1. Dans quel cas tu auras encore des doublons malgré l’idempotence?
