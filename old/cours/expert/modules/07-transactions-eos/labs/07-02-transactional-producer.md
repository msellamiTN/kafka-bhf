# Lab 07.02 — Transactional Producer (commit vs abort)

## Objectif

- Produire des messages en **transactions**
- Générer des transactions **abortées** et observer leur visibilité

## Pré-requis

- Stack: `docker/single-broker`

## Étapes

1. Démarrer Kafka:

   - `docker compose -f docker/single-broker/docker-compose.yml up -d`

1. Créer un topic:

```powershell
docker exec -it kafka kafka-topics --bootstrap-server localhost:9093 --create --topic expert07-txn --partitions 3 --replication-factor 1
```

1. Lancer le producer transactionnel (runnable)

- Ici on abort **1 transaction sur 2** (`abortEveryTxn=2`).

Depuis `book-spring-microservices/code`:

```powershell
mvn -pl kafka-labs -Dexec.mainClass=com.data2ai.kafkacourse.labs.producer.TransactionalProducerApp exec:java -Dexec.args="expert07-txn localhost:9092 txn-producer-demo 40 2"
```

1. Comparer read_uncommitted vs read_committed

- Lecture par défaut (read_uncommitted):

```powershell
docker exec -it kafka kafka-console-consumer --bootstrap-server localhost:9093 --topic expert07-txn --from-beginning --property print.key=true --property print.offset=true
```

- Lecture read_committed:

```powershell
docker exec -it kafka kafka-console-consumer --bootstrap-server localhost:9093 --topic expert07-txn --from-beginning --consumer-property isolation.level=read_committed --property print.key=true --property print.offset=true
```

## Checkpoint

1. Quelle est la différence entre idempotent et transactional producer?
1. Que garantit `read_committed`?
