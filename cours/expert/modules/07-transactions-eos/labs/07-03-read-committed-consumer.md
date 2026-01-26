# Lab 07.03 — Consumer `read_committed` + commits manuels

## Objectif

- Lire uniquement les données **committed**
- Contrôler les offsets via commit manuel

## Pré-requis

- Avoir un topic alimenté par le Lab 07.02 (`expert07-txn`)

## Étapes

1. Lancer un consumer Java `read_committed` (runnable)

Depuis `book-spring-microservices/code`:

```powershell
mvn -pl kafka-labs -Dexec.mainClass=com.data2ai.kafkacourse.labs.consumer.ReadCommittedConsumerApp exec:java -Dexec.args="expert07-txn localhost:9092 expert07-read-committed"
```

1. Observer les offsets côté broker

```powershell
docker exec -it kafka kafka-consumer-groups --bootstrap-server localhost:9093 --group expert07-read-committed --describe
```

## Checkpoint

1. Pourquoi `enable.auto.commit=false` est recommandé ici?
1. Différence entre commit “après traitement” vs “avant traitement”?
