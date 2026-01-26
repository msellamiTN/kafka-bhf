# Module 6: Security & Authentication (SASL/PLAIN baseline)

## Goal

- Start a broker with SASL/PLAIN enabled
- Use a client config to run admin commands

## Start stack

- `docker compose -f docker/security/docker-compose.yml up -d`

Endpoints:

- Kafka (host): `localhost:9092`
- Kafka UI: `http://localhost:8080`

## Client auth (inside the container)

This stack mounts:

- `/etc/kafka/client.properties`

Use `--command-config /etc/kafka/client.properties` for CLI commands.

### List topics

- `docker exec -it kafka kafka-topics --bootstrap-server kafka:9093 --command-config /etc/kafka/client.properties --list`

### Create topic

- `docker exec -it kafka kafka-topics --bootstrap-server kafka:9093 --command-config /etc/kafka/client.properties --create --topic secure-topic --partitions 3 --replication-factor 1`

## Notes

- This stack is a **baseline** for Module 6. You can extend it with:
  - SSL/TLS (keystore/truststore)
  - SASL/SCRAM
  - Proper ACL enforcement (`allow.everyone.if.no.acl.found=false`) + explicit ACLs

## Tear down

- `docker compose -f docker/security/docker-compose.yml down -v`
