# 📅 Jour 2 - Développement Avancé & Kafka Streams

## Objectifs de la journée

À la fin de cette journée, vous serez capable de :
- Implémenter des patterns professionnels (Dead Letter Topics, retries)
- Gérer le rebalancing et les erreurs dans les consumers
- Créer des applications Kafka Streams pour le traitement temps réel
- Maîtriser les opérations KStream/KTable

## Modules

| Module | Durée | Description |
|--------|-------|-------------|
| [Module 04 - Patterns Avancés](./module-04-advanced-patterns/) | 3h | DLT, retries, rebalancing, gestion d'erreurs |
| [Module 05 - Kafka Streams](./module-05-kafka-streams/) | 3h | KStream, KTable, agrégations temps réel |

## Prérequis

- ✅ Avoir complété le Jour 1
- ✅ Cluster Kafka opérationnel
- ✅ Familiarité avec les APIs Producer/Consumer

## Démarrage rapide

```bash
cd formation-v2/

# Démarrer l'infrastructure
./scripts/up.sh

# Module 04
docker compose -f day-02-development/module-04-advanced-patterns/docker-compose.module.yml up -d --build

# Module 05
docker compose -f day-02-development/module-05-kafka-streams/docker-compose.module.yml up -d --build
```
