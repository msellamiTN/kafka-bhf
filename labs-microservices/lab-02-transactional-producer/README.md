# Lab 02 - Transactional Producer

## Objectives

- Understand transactional producer semantics
- Configure `transactional.id` and transactional guarantees
- Test commit vs abort behavior

## Quick Start

### Local

```bash
mvn spring-boot:run
```

### Docker

```bash
docker build -t lab-02-transactional-producer .
docker run --rm -e KAFKA_BOOTSTRAP_SERVERS=kafka:29092 lab-02-transactional-producer
```

### Verify

```bash
kafka-console-consumer --bootstrap-server localhost:9092 --topic lab02-transactional-topic --from-beginning --isolation-level read_committed
```

## Key Configuration

```properties
transactional.id=lab02-transactional-producer
enable.idempotence=true
acks=all
```

## Testing

- Set `shouldCommit=false` in code to test abort
- Observe that aborted transactions are not visible to read_committed consumers
