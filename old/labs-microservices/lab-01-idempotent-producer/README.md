# Lab 01 - Idempotent Producer

## Objectives
- Understand idempotent producer constraints
- Configure `enable.idempotence=true`, `acks=all`, `max.in.flight.requests.per.connection<=5`
- Verify exactly-once delivery semantics

## Quick Start

### Local
```bash
mvn spring-boot:run -Dspring-boot.run.arguments="--lab.topic=lab01-idempotent-topic"
```

### Docker
```bash
docker build -t lab-01-idempotent-producer .
docker run --rm -e KAFKA_BOOTSTRAP_SERVERS=kafka:29092 lab-01-idempotent-producer
```

### Verify
```bash
kafka-console-consumer --bootstrap-server localhost:9092 --topic lab01-idempotent-topic --from-beginning
```

## Key Configuration
```properties
enable.idempotence=true
acks=all
retries=Integer.MAX_VALUE
max.in.flight.requests.per.connection=5
```
