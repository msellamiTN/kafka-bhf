# Module 11: Multi-Cluster Replication (MirrorMaker 2)

## Goal

- Run two Kafka clusters (source + target)
- Replicate topics from source to target using MirrorMaker 2

## Start stack

- `docker compose -f docker/multi-cluster/docker-compose.yml up -d`

Endpoints:

- Source Kafka (host): `localhost:9092`
- Target Kafka (host): `localhost:19092`
- Kafka UI: `http://localhost:8080`

## Create a demo topic on source

The MM2 config replicates only topics matching: `mm2-demo-.*`.

- Create:
  - `docker exec -it kafka-a kafka-topics --create --topic mm2-demo-01 --bootstrap-server kafka-a:9093 --partitions 3 --replication-factor 1`

## Produce to source

- `docker exec -it kafka-a kafka-console-producer --topic mm2-demo-01 --bootstrap-server kafka-a:9093`

Type a few messages and exit.

## Consume from target

- `docker exec -it kafka-b kafka-console-consumer --topic mm2-demo-01 --bootstrap-server kafka-b:9093 --from-beginning`

If replication is working, you should see the messages you produced in the source cluster.

## Tear down

- `docker compose -f docker/multi-cluster/docker-compose.yml down -v`
