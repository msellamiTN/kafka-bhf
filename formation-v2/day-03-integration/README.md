# 📅 Jour 3 - Kafka Connect, Tests & Observabilité

## Objectifs de la journée

À la fin de cette journée, vous serez capable de :
- Déployer et configurer des connecteurs Kafka Connect
- Tester vos applications Kafka avec Testcontainers
- Monitorer et observer vos applications Kafka en production

## Modules

| Module | Durée | Description |
|--------|-------|-------------|
| [Module 06 - Kafka Connect](./module-06-kafka-connect/) | 2h | Source/Sink connectors, configuration |
| [Module 07 - Tests](./module-07-testing/) | 2h | Testcontainers, mocking, tests d'intégration |
| [Module 08 - Observabilité](./module-08-observability/) | 2h | JMX, métriques, consumer lag, tracing |

## Prérequis

- ✅ Avoir complété les Jours 1 et 2
- ✅ Cluster Kafka opérationnel
- ✅ Familiarité avec Kafka Streams

## Démarrage rapide

```bash
cd formation-v2/

# Démarrer l'infrastructure
./scripts/up.sh

# Module 06 - Kafka Connect
docker compose -f day-03-integration/module-06-kafka-connect/docker-compose.module.yml up -d

# Module 07 - Tests (exécution locale)
cd day-03-integration/module-07-testing/java && mvn test

# Module 08 - Observabilité
docker compose -f day-03-integration/module-08-observability/docker-compose.module.yml up -d
```
