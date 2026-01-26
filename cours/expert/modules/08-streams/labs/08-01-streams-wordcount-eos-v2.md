# Lab 08.01 — Kafka Streams WordCount en exactly_once_v2

## Objectif

- Construire une topology simple (WordCount)
- Activer EOS v2:
  - `processing.guarantee=exactly_once_v2`

## Pré-requis

- Broker 2.5+ (OK en stacks Confluent récentes)

## Exécution (runnable)

### Préparer Kafka

- Démarrer un broker local:

  - `docker compose -f docker/single-broker/docker-compose.yml up -d`

- Créer les topics:

```powershell
docker exec -it kafka kafka-topics --create --topic text-input --bootstrap-server localhost:9093 --partitions 3 --replication-factor 1
docker exec -it kafka kafka-topics --create --topic word-count-output --bootstrap-server localhost:9093 --partitions 3 --replication-factor 1
```

### Lancer l’app Streams (EOS v2)

Depuis `book-spring-microservices/code`:

```powershell
mvn -pl streams-labs -Dexec.mainClass=com.data2ai.kafkacourse.labs.streams.WordCountExactlyOnceV2App exec:java -Dexec.args="localhost:9092 text-input word-count-output wordcount-eosv2"
```

### Produire des lignes de texte

```powershell
docker exec -it kafka kafka-console-producer --topic text-input --bootstrap-server localhost:9093
```

Exemples:

- `hello world kafka streams`
- `kafka kafka hello`

### Consommer les comptages

```powershell
docker exec -it kafka kafka-console-consumer --topic word-count-output --bootstrap-server localhost:9093 --from-beginning --property print.key=true --property key.separator=" => " --property value.deserializer=org.apache.kafka.common.serialization.LongDeserializer
```

## Checkpoint

1. Pourquoi EOS v2 est recommandé?
2. Quel est le coût (latence/throughput)?
