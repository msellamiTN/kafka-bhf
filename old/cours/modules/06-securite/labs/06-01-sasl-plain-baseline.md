# Lab 06.01 — SASL/PLAIN baseline (pratique)

## Objectif

- Démarrer un broker avec SASL/PLAIN
- Utiliser un fichier client (`client.properties`) pour exécuter la CLI

## Démarrer la stack

- `docker compose -f docker/security/docker-compose.yml up -d`

Endpoints:

- Kafka (host): `localhost:9092`
- Kafka UI: `http://localhost:8080`

## Comprendre les fichiers

Dans `docker/security/`:

- `kafka_server_jaas.conf` (côté broker)
- `client.properties` (côté client)

## Lister les topics (avec auth)

```powershell
docker exec -it kafka kafka-topics --bootstrap-server kafka:9093 --command-config /etc/kafka/client.properties --list
```

## Créer un topic (avec auth)

```powershell
docker exec -it kafka kafka-topics --bootstrap-server kafka:9093 --command-config /etc/kafka/client.properties --create --topic secure-topic --partitions 3 --replication-factor 1
```

## Drill

- Décrire le topic:

```powershell
docker exec -it kafka kafka-topics --bootstrap-server kafka:9093 --command-config /etc/kafka/client.properties --describe --topic secure-topic
```

## Checkpoint (exam style)

1. Quelle est la différence entre SASL_PLAINTEXT et SASL_SSL?
2. À quoi sert un fichier `--command-config`?

## Reset

- `docker compose -f docker/security/docker-compose.yml down -v`
