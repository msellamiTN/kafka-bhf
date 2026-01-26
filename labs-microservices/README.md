# Labs Microservices - Kafka Course

Collection de 5 projets microservices autonomes pour les labs Kafka, avec Dockerisation et configuration prête pour l'exécution.

## Structure

```
labs-microservices/
├── lab-01-idempotent-producer/          # Producteur idempotent
├── lab-02-transactional-producer/       # Producteur transactionnel
├── lab-03-read-committed-consumer/      # Consommateur read_committed
├── lab-04-eos-read-process-write/       # EOS read-process-write
├── lab-05-streams-wordcount-eos-v2/     # Kafka Streams EOS v2
├── docker-compose.yml                    # Stack complet avec profiles
└── pom.xml                              # Parent Maven
```

## Démarrage rapide

### 1) Construire tous les labs
```bash
mvn clean package -DskipTests
```

### 2) Démarrer Kafka
```bash
docker-compose up zookeeper kafka -d
```

### 3) Lancer un lab spécifique
```bash
# Lab 01: Idempotent Producer
docker-compose --profile lab01 up lab-01-idempotent-producer

# Lab 02: Transactional Producer
docker-compose --profile lab02 up lab-02-transactional-producer

# Lab 03: Read-Committed Consumer
docker-compose --profile lab03 up lab-03-read-committed-consumer

# Lab 04: End-to-End EOS
docker-compose --profile lab04 up lab-04-eos-read-process-write

# Lab 05: Kafka Streams WordCount EOS v2
docker-compose --profile lab05 up lab-05-streams-wordcount-eos-v2
```

### 4) Vérifier avec Kafka CLI
```bash
# Lister les topics
kafka-topics --bootstrap-server localhost:9092 --list

# Consommer les résultats
kafka-console-consumer --bootstrap-server localhost:9092 --topic <topic-name> --from-beginning
```

## Labs disponibles

### Lab 01 - Idempotent Producer
- **Objectif**: Comprendre les contraintes du producteur idempotent
- **Configuration**: `enable.idempotence=true`, `acks=all`
- **Topic**: `lab01-idempotent-topic`

### Lab 02 - Transactional Producer
- **Objectif**: Maîtriser les transactions producteur
- **Configuration**: `transactional.id`, commit/abort
- **Topic**: `lab02-transactional-topic`

### Lab 03 - Read-Committed Consumer
- **Objectif**: Isolation read_committed vs read_uncommitted
- **Configuration**: `isolation.level=read_committed`
- **Topic**: `lab02-transactional-topic`

### Lab 04 - End-to-End EOS
- **Objectif**: Read-Process-Write avec transactions
- **Configuration**: Consumer read_committed + Producer transactionnel
- **Topics**: Input `lab02-transactional-topic`, Output `lab04-eos-output-topic`

### Lab 05 - Kafka Streams EOS v2
- **Objectif**: Streams avec exactly-once v2
- **Configuration**: `processing.guarantee=exactly_once_v2`
- **Topics**: Input `lab05-text-input-topic`, Output `lab05-wordcount-output-topic`

## Configuration Docker

Tous les labs sont configurés pour:
- **Kafka**: `kafka:29092` (réseau Docker)
- **State dir**: `/tmp/kafka-streams/labXX` (pour Streams)
- **Logging**: Level INFO pour les labs, WARN pour Kafka

## Nettoyage

```bash
# Arrêter tous les services
docker-compose down

# Nettoyer les volumes Kafka
docker-compose down -v

# Supprimer les images construites
docker rmi $(docker images "lab-*" -q)
```
