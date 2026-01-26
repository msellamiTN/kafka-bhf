# Module 1: Installation & First Messages (Docker)

## Goal

- Bring up Kafka via Docker Compose
- Create topics, produce, consume, inspect consumer groups
- (Optional) run a 3-broker cluster to see replication/ISR

## Option A: ZooKeeper single-broker (matches the base labs)

- Start:
  - `docker compose -f docker/single-broker/docker-compose.yml up -d`
- Kafka (host): `localhost:9092`
- Kafka UI: `http://localhost:8080`

### Verify broker

- `docker exec -it kafka kafka-broker-api-versions --bootstrap-server localhost:9093`

### Topic operations

- Create a topic:
  - `docker exec -it kafka kafka-topics --create --topic test-topic --bootstrap-server localhost:9093 --partitions 3 --replication-factor 1`
- List topics:
  - `docker exec -it kafka kafka-topics --list --bootstrap-server localhost:9093`
- Describe topic:
  - `docker exec -it kafka kafka-topics --describe --topic test-topic --bootstrap-server localhost:9093`

### Produce and consume

- Produce:
  - `docker exec -it kafka kafka-console-producer --topic test-topic --bootstrap-server localhost:9093`
- Consume from beginning:
  - `docker exec -it kafka kafka-console-consumer --topic test-topic --bootstrap-server localhost:9093 --from-beginning`

### Consumer groups

- Start a consumer group:
  - `docker exec -it kafka kafka-console-consumer --topic test-topic --bootstrap-server localhost:9093 --group demo-group --from-beginning`
- Inspect group lag:
  - `docker exec -it kafka kafka-consumer-groups --bootstrap-server localhost:9093 --group demo-group --describe`

## Option B: KRaft single-broker (no ZooKeeper)

- Start:
  - `docker compose -f docker/kraft-single-broker/docker-compose.yml up -d`
- Kafka (host): `localhost:9092`
- Kafka UI: `http://localhost:8080`

## Option C: ZooKeeper multi-broker (replication)

- Start:
  - `docker compose -f docker/multi-broker/docker-compose.yml up -d`
- Brokers (host):
  - `localhost:9092`, `localhost:9093`, `localhost:9094`
- Kafka UI: `http://localhost:8080`

### Create a replicated topic

- `docker exec -it kafka1 kafka-topics --create --topic replicated-topic --bootstrap-server kafka1:29092 --partitions 6 --replication-factor 3`
- `docker exec -it kafka1 kafka-topics --describe --topic replicated-topic --bootstrap-server kafka1:29092`

## Tear down

- Stop:
  - `docker compose -f <compose-file> down`
- Full reset (delete volumes):
  - `docker compose -f <compose-file> down -v`
