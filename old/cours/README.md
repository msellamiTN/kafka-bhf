# Cours Auto-rythmé CCDAK (Apache Kafka) — Labs Docker + Java/Spring

Ce dossier transforme les labs existants de ce repo en **parcours de formation complet, auto-rythmé**, orienté **Confluent Certified Developer for Apache Kafka (CCDAK)**.

## Public visé

- Développeurs Java (ou JVM) qui veulent **construire** et **dépanner** des applications Kafka.
- Data engineers / solutions architects souhaitant pratiquer Kafka « côté dev ».

## Pré-requis

- Java **11+**
- Docker Desktop + Docker Compose v2 (`docker compose`)
- Une base en HTTP/JSON et en architecture distribuée

## Comment utiliser ce cours

- **Rythme**: 1 module = 1 à 3 sessions (selon ton temps)
- **Livrables**: à la fin de chaque module
  - tu sais exécuter les commandes clés,
  - tu as un mini-projet ou un exercice corrigé,
  - tu as un “checkpoint exam” (questions types CCDAK).

## Conventions

- Les labs « plateforme » utilisent les stacks Docker dans `../docker/`.
- Les commandes sont données pour:
  - **Windows/PowerShell** (prioritaire)
  - et `docker exec` (portable)

## Table des modules (CCDAK)

- **Module 01 — Fondations & CLI**
  - Objectif: lancer Kafka localement, maîtriser topics/partitions/groups
  - Dossier: `modules/01-fondations/`

- **Module 02 — Producer & Consumer (Java)**
  - Objectif: producer/consumer robustes, offset management, erreurs
  - Dossier: `modules/02-producer-consumer/`

- **Module 03 — Schema Registry & Avro**
  - Objectif: contrat de données, compatibilité, serializers
  - Dossier: `modules/03-schema-registry/`

- **Module 04 — Kafka Streams**
  - Objectif: DSL, state stores, exactly-once, patterns
  - Dossier: `modules/04-streams/`

- **Module 05 — Kafka Connect**
  - Objectif: connectors, REST API, DLQ, déploiement
  - Dossier: `modules/05-connect/`

- **Module 06 — Sécurité**
  - Objectif: SASL/PLAIN, SCRAM, ACLs, TLS (progressif)
  - Dossier: `modules/06-securite/`

- **Module 07 — Transactions & Exactly-Once**
  - Objectif: idempotence, transactions, read_committed
  - Dossier: `modules/07-transactions/`

- **Module 08 — Observabilité**
  - Objectif: métriques, Prometheus, Grafana, lag
  - Dossier: `modules/08-observabilite/`

- **Module 09 — Performance Tuning**
  - Objectif: producer/consumer/broker tuning + bench
  - Dossier: `modules/09-performance/`

- **Module 10 — ksqlDB**
  - Objectif: streams/tables SQL, requêtes continues
  - Dossier: `modules/10-ksqldb/`

- **Module 11 — Multi-Cluster (MM2)**
  - Objectif: réplication, DR, offset translation
  - Dossier: `modules/11-multi-cluster/`

- **Module 12 — Tests**
  - Objectif: tests d’intégration, Testcontainers, patterns
  - Dossier: `modules/12-tests/`

- **Module 13 — Ops & Admin**
  - Objectif: sizing, rebalancing, upgrades
  - Dossier: `modules/13-admin/`

## Parcours Expert (80–100h)

Si tu veux une formation **plus longue** (13 modules en 4 phases) avec capstone, utilise:

- `expert/README.md`

## Examen CCDAK

- Conseils + stratégie: `exam/ccdak-exam-tips.md`
- Drills CLI: `ressources/drills-cli.md`

## Annexes

- Cheatsheets: `ressources/`
- Mini-livre Java/Spring microservices: `../book-spring-microservices/`
