# Lab 04 - End-to-End EOS (Read-Process-Write)

## Objectives

- Implement exactly-once semantics with read-process-write pattern
- Combine consumer read_committed with transactional producer
- Commit offsets within the transaction

## Quick Start

### Local

```bash
mvn spring-boot:run
```

### Docker

```bash
docker build -t lab-04-eos-read-process-write .
docker run --rm -e KAFKA_BOOTSTRAP_SERVERS=kafka:29092 lab-04-eos-read-process-write
```

## Key Configuration

```properties
# Consumer
isolation.level=read_committed
enable.auto.commit=false

# Producer
transactional.id=lab04-eos-transactional
enable.idempotence=true
```

## Testing

1. Start Lab 02 (Transactional Producer) to generate input
2. Start this lab - it will process and output to `lab04-eos-output-topic`
3. Verify output with read_committed consumer:

```bash
kafka-console-consumer --bootstrap-server localhost:9092 --topic lab04-eos-output-topic --from-beginning --isolation-level read_committed
```

## EOS Guarantees

- No duplicate processing
- No lost messages
- Atomic offset commits with output
