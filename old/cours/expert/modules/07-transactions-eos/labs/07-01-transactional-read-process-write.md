# Lab 07.01 — Read-process-write en transaction (EOS)

## Objectif

- Implémenter un pipeline EOS:
  - consumer `read_committed`
  - producer transactionnel
  - commit offsets dans la transaction

## Rappel

- Producer:
  - `enable.idempotence=true`
  - `transactional.id=...`
- Consumer:
  - `isolation.level=read_committed`

## Exécution (runnable)

### Préparer Kafka

- Démarrer un broker local:

  - `docker compose -f docker/single-broker/docker-compose.yml up -d`

- Créer les topics:

```powershell
docker exec -it kafka kafka-topics --bootstrap-server localhost:9093 --create --topic txn-input --partitions 3 --replication-factor 1
docker exec -it kafka kafka-topics --bootstrap-server localhost:9093 --create --topic txn-output --partitions 3 --replication-factor 1
```

### Lancer l’app read-process-write

Depuis `book-spring-microservices/code`:

```powershell
mvn -pl kafka-labs -Dexec.mainClass=com.data2ai.kafkacourse.labs.transactions.ReadProcessWriteTransactionalApp exec:java -Dexec.args="txn-input txn-output localhost:9092 txn-rpw-group txn-rpw-1"
```

### Produire des messages en entrée

```powershell
docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9093 --topic txn-input --property parse.key=true --property key.separator=:
```

Exemples:

- `a:hello`
- `b:world`

### Vérifier la sortie

```powershell
docker exec -it kafka kafka-console-consumer --bootstrap-server localhost:9093 --topic txn-output --from-beginning --property print.key=true --property print.offset=true
```

## Checkpoint

1. Différence idempotent vs transactional?
2. Que se passe-t-il si le process crash au milieu?
