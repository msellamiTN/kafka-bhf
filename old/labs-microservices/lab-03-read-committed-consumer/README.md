# Lab 03 - Read-Committed Consumer

## Objectives

- Understand read_committed isolation level
- Configure manual offset commits
- Observe transactional visibility (committed vs aborted)

## Quick Start

### Local

```bash
mvn spring-boot:run
```

### Docker

```bash
docker build -t lab-03-read-committed-consumer .
docker run --rm -e KAFKA_BOOTSTRAP_SERVERS=kafka:29092 lab-03-read-committed-consumer
```

## Key Configuration

```properties
isolation.level=read_committed
enable.auto.commit=false
auto.offset.reset=earliest
```

## Testing

1. Start Lab 02 (Transactional Producer) with `shouldCommit=true`
2. Start this consumer - observe committed messages
3. Start Lab 02 with `shouldCommit=false` - observe no aborted messages appear

## Comparison

- Use `isolation.level=read_uncommitted` to see all messages (including aborted)
- Compare behavior with `read_committed`
