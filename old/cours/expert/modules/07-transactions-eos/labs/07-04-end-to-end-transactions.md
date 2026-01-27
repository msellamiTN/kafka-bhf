# Lab 07.04 — End-to-End EOS: consume-process-produce + offsets dans la transaction

## Objectif

- Mettre en place un vrai pipeline EOS:
  - consumer `read_committed`
  - producer transactionnel
  - commit des offsets **dans la transaction**

## Pré-requis

- Stack: `docker/single-broker`

## Étapes

1. Démarrer Kafka:

   - `docker compose -f docker/single-broker/docker-compose.yml up -d`

1. Créer `txn-input` et `txn-output`:

```powershell
docker exec -it kafka kafka-topics --bootstrap-server localhost:9093 --create --topic txn-input --partitions 3 --replication-factor 1
docker exec -it kafka kafka-topics --bootstrap-server localhost:9093 --create --topic txn-output --partitions 3 --replication-factor 1
```

1. Lancer l’app (runnable)

Depuis `book-spring-microservices/code`:

```powershell
mvn -pl kafka-labs -Dexec.mainClass=com.data2ai.kafkacourse.labs.transactions.ReadProcessWriteTransactionalApp exec:java -Dexec.args="txn-input txn-output localhost:9092 txn-rpw-group txn-rpw-1"
```

1. Produire en entrée:

```powershell
docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9093 --topic txn-input --property parse.key=true --property key.separator=:
```

Exemples:

- `a:hello`
- `b:world`

1. Consommer la sortie:

```powershell
docker exec -it kafka kafka-console-consumer --bootstrap-server localhost:9093 --topic txn-output --from-beginning --property print.key=true --property print.offset=true
```

## Checkpoint

1. Pourquoi `sendOffsetsToTransaction` est la clé EOS?
1. Qu’arrive-t-il si l’app crash après `produce` mais avant `commitTransaction`?
