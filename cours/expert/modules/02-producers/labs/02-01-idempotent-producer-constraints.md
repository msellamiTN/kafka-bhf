# Lab 02.01 — Idempotent producer: contraintes et garanties

## Objectif

- Comprendre pourquoi `enable.idempotence=true` réduit les doublons
- Connaître les contraintes associées (exam + prod)

## Rappel (essentiel)

Idempotence ON implique un mode “safe”:

- `enable.idempotence=true`
- `acks=all`
- `max.in.flight.requests.per.connection<=5`

## Exercice

1. Démarrer un broker local:

   - `docker compose -f docker/single-broker/docker-compose.yml up -d`

1. Créer un topic:

```powershell
docker exec -it kafka kafka-topics --bootstrap-server localhost:9093 --create --topic expert02-events --partitions 3 --replication-factor 1
```

1. Implémenter (Java) un producer qui logge `RecordMetadata` avec:

   - `enable.idempotence=true`
   - `acks=all`
   - `max.in.flight.requests.per.connection=5`
   - `retries` (ex: 10)

## Exécution (runnable)

Depuis `book-spring-microservices/code`:

```powershell
mvn -pl kafka-labs -Dexec.mainClass=com.data2ai.kafkacourse.labs.producer.IdempotentProducerApp exec:java -Dexec.args="expert02-events localhost:9092 100"
```

Vérifier côté consumer (dans le container Kafka):

```powershell
docker exec -it kafka kafka-console-consumer --bootstrap-server localhost:9093 --topic expert02-events --from-beginning --property print.key=true --property print.partition=true --property print.offset=true
```

## Checkpoint

1. Pourquoi `acks=all` est requis?
2. Pourquoi la limite `max.in.flight...<=5`?
3. Idempotence = exactly-once?
