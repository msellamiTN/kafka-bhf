# Lab 05 - Kafka Streams WordCount EOS v2

## Objectives

- Understand Kafka Streams exactly-once semantics v2
- Configure `processing.guarantee=exactly_once_v2`
- Build stateful streaming application (WordCount)

## Quick Start

### Local

```bash
mvn spring-boot:run
```

### Docker

```bash
docker build -t lab-05-streams-wordcount-eos-v2 .
docker run --rm -e KAFKA_BOOTSTRAP_SERVERS=kafka:29092 lab-05-streams-wordcount-eos-v2
```

## Key Configuration

```properties
processing.guarantee=exactly_once_v2
state.dir=/tmp/kafka-streams/lab05
```

## Testing

1. Create input topic:

```bash
kafka-topics --create --topic lab05-text-input-topic --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
```

2. Send test data:

```bash
kafka-console-producer --topic lab05-text-input-topic --bootstrap-server localhost:9092
> hello world
> hello kafka
> hello streams
```

3. Verify output:

```bash
kafka-console-consumer --topic lab05-wordcount-output-topic --bootstrap-server localhost:9092 --from-beginning --property print.key=true --property key.separator="="
```

## EOS v2 Benefits

- Improved recovery time
- Reduced coordination overhead
- Better scalability than EOS v1
